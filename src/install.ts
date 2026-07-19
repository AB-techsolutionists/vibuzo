import { existsSync } from "node:fs";
import { join } from "node:path";
import { spawn } from "node:child_process";
import type { ChildProcess, SpawnOptions } from "node:child_process";
import { writeFileAtomic } from "./utils/fs.js";
import { SYSTEM_PROMPT } from "./prompt.js";
import type { DetectedTool, InstallSummary } from "./types.js";

export interface InstallOptions {
  projectDir: string;
  detectedTools: DetectedTool[];
  yes?: boolean;
}

const OPENCODE_AGENT_FRONTMATTER = `---
mode: primary
hidden: false
color: emerald
---
`;

const AGENTS_SKELETON = `# ===========================================
# Project Context
# ===========================================
`;

const CLAUDE_MD_SKELETON = `# ===========================================
# Project Context
# ===========================================
`;

function openCodeAgentPath(projectDir: string): string {
  return join(projectDir, ".opencode", "agent", "deepveloper.md");
}

function claudeCodeAgentPath(projectDir: string): string {
  return join(projectDir, ".claude", "deepveloper.md");
}

function claudeMdPath(projectDir: string): string {
  return join(projectDir, "CLAUDE.md");
}

function agentsPath(projectDir: string): string {
  return join(projectDir, "AGENTS.md");
}

async function writeWithOverwriteCheck(
  filePath: string,
  content: string,
  yes: boolean,
  written: string[],
  skipped: string[],
): Promise<void> {
  if (existsSync(filePath)) {
    if (yes) {
      skipped.push(filePath);
      return;
    }
    console.warn(`Warning: ${filePath} already exists — overwriting.`);
  }
  await writeFileAtomic(filePath, content);
  written.push(filePath);
}

export async function installDeepveloper(
  options: InstallOptions,
): Promise<InstallSummary> {
  const { projectDir, detectedTools, yes = false } = options;
  const written: string[] = [];
  const skipped: string[] = [];
  const hasOpenCode = detectedTools.includes("opencode");
  const hasClaudeCode = detectedTools.includes("claude-code");

  if (hasOpenCode) {
    const agentContent = OPENCODE_AGENT_FRONTMATTER + SYSTEM_PROMPT;
    await writeWithOverwriteCheck(
      openCodeAgentPath(projectDir),
      agentContent,
      yes,
      written,
      skipped,
    );

    const agents = agentsPath(projectDir);
    await writeWithOverwriteCheck(
      agents,
      AGENTS_SKELETON,
      yes,
      written,
      skipped,
    );
  }

  if (hasClaudeCode) {
    await writeWithOverwriteCheck(
      claudeCodeAgentPath(projectDir),
      SYSTEM_PROMPT,
      yes,
      written,
      skipped,
    );

    const claudeMd = claudeMdPath(projectDir);
    await writeWithOverwriteCheck(
      claudeMd,
      CLAUDE_MD_SKELETON,
      yes,
      written,
      skipped,
    );
  }

  return { written, skipped, toolDetected: detectedTools };
}

export type SpawnFunction = (
  command: string,
  args: string[],
  options: SpawnOptions,
) => ChildProcess;

export async function installSkills(
  spawnFn: SpawnFunction = spawn,
): Promise<void> {
  const options: SpawnOptions = { stdio: "inherit", shell: true };
  return new Promise<void>((resolve, reject) => {
    const child = spawnFn(
      "npx",
      ["skills@latest", "add", "mattpocock/skills"],
      options,
    );
    child.on("close", (code) => {
      if (code === 0) resolve();
      else reject(new Error(`npx skills exited with code ${code}`));
    });
    child.on("error", (err) => reject(err));
  });
}
