import { existsSync } from "node:fs";
import { join } from "node:path";
import { writeFileSafe } from "./utils/fs.js";
import { SYSTEM_PROMPT } from "./prompt.js";
import type { DetectedTool, InstallSummary } from "./types.js";

export interface InstallOptions {
  projectDir: string;
  detectedTools: DetectedTool[];
  yes?: boolean;
  confirmOverwrite?: (filePath: string) => Promise<boolean>;
}

export const OPENCODE_AGENT_FRONTMATTER = `---
description: Senior software engineer AI agent with Karpathy principles and Matt Pocock's engineering skills
mode: primary
hidden: false
---
`;

function openCodeAgentPath(projectDir: string): string {
  return join(projectDir, ".opencode", "agents", "deepveloper.md");
}

function claudeCodeAgentPath(projectDir: string): string {
  return join(projectDir, ".claude", "deepveloper.md");
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
    await writeWithOverwriteCheck(
      openCodeAgentPath(projectDir),
      OPENCODE_AGENT_FRONTMATTER + SYSTEM_PROMPT,
      yes,
      summary,
      confirmOverwrite,
    );
  }

  if (hasClaudeCode) {
    await writeWithOverwriteCheck(
      claudeCodeAgentPath(projectDir),
      SYSTEM_PROMPT,
      yes,
      summary,
      confirmOverwrite,
    );
  }

  return { written, skipped, toolDetected: detectedTools };
}

export function buildSkillsGuide(detectedTools: DetectedTool[]): string {
  const lines = [
    "Install Matt Pocock's engineering skills (code-review, TDD,",
    "domain-modeling, grilling, and more) with one command:",
    "",
    "  npx skills@latest add mattpocock/skills",
  ];
  if (detectedTools.includes("opencode")) {
    lines.push(
      "",
      "In opencode:",
      "  • Open this project in opencode",
      "  • Cycle to the deepveloper agent with Tab (agent selector)",
      "  • Run /setup-matt-pocock-skills to configure the repo",
    );
  }
  if (detectedTools.includes("claude-code")) {
    lines.push(
      "",
      "In Claude Code:",
      "  • Open this project in Claude Code",
      "  • Run /setup-matt-pocock-skills to configure the repo",
    );
  }
  return lines.join("\n");
}
