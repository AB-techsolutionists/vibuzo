import { existsSync } from "node:fs";
import { join } from "node:path";
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

function openCodeAgentPath(projectDir: string): string {
  return join(projectDir, ".opencode", "agent", "deepveloper.md");
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

  return { written, skipped, toolDetected: detectedTools };
}
