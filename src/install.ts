import { existsSync } from "node:fs";
import { join } from "node:path";
import { spawn } from "node:child_process";
import type { ChildProcess, SpawnOptions } from "node:child_process";
import { writeFileSafe } from "./utils/fs.js";
import { SYSTEM_PROMPT } from "./prompt.js";
import type { DetectedTool, InstallSummary } from "./types.js";

export interface InstallOptions {
  projectDir: string;
  detectedTools: DetectedTool[];
  yes?: boolean;
  confirmOverwrite?: (filePath: string) => Promise<boolean>;
}

const OPENCODE_AGENT_FRONTMATTER = `---
mode: primary
hidden: false
color: emerald
---
`;

const PROJECT_CONTEXT_SKELETON = `# ===========================================
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
  summary: { written: string[]; skipped: string[] },
  confirmOverwrite?: (filePath: string) => Promise<boolean>,
): Promise<void> {
  if (existsSync(filePath)) {
    if (yes) {
      summary.skipped.push(filePath);
      return;
    }
    if (confirmOverwrite) {
      const ok = await confirmOverwrite(filePath);
      if (!ok) {
        summary.skipped.push(filePath);
        return;
      }
    }
    console.warn(`Warning: ${filePath} already exists — overwriting.`);
  }
  await writeFileSafe(filePath, content);
  summary.written.push(filePath);
}

type ToolFiles = {
  agentPath: string;
  agentContent: string;
  skeletonPath: string;
};

async function installToolFiles(
  files: ToolFiles,
  yes: boolean,
  summary: { written: string[]; skipped: string[] },
  confirmOverwrite?: (filePath: string) => Promise<boolean>,
): Promise<void> {
  await writeWithOverwriteCheck(files.agentPath, files.agentContent, yes, summary, confirmOverwrite);
  await writeWithOverwriteCheck(files.skeletonPath, PROJECT_CONTEXT_SKELETON, yes, summary, confirmOverwrite);
}

export async function installDeepveloper(
  options: InstallOptions,
): Promise<InstallSummary> {
  const { projectDir, detectedTools, yes = false, confirmOverwrite } = options;
  const written: string[] = [];
  const skipped: string[] = [];
  const summary = { written, skipped };
  const hasOpenCode = detectedTools.includes("opencode");
  const hasClaudeCode = detectedTools.includes("claude-code");

  if (hasOpenCode) {
    await installToolFiles({
      agentPath: openCodeAgentPath(projectDir),
      agentContent: OPENCODE_AGENT_FRONTMATTER + SYSTEM_PROMPT,
      skeletonPath: agentsPath(projectDir),
    }, yes, summary, confirmOverwrite);
  }

  if (hasClaudeCode) {
    await installToolFiles({
      agentPath: claudeCodeAgentPath(projectDir),
      agentContent: SYSTEM_PROMPT,
      skeletonPath: claudeMdPath(projectDir),
    }, yes, summary, confirmOverwrite);
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
