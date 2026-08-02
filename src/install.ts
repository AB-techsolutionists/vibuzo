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
  onProgress?: (filePath: string, index: number, total: number) => void | Promise<void>;
}

export const OPENCODE_AGENT_FRONTMATTER = `---
description: Senior software engineer AI agent with Karpathy principles and Matt Pocock's engineering skills
mode: primary
hidden: false
---
`;

export const AGENT_FILES: Record<DetectedTool, string> = {
  opencode: join(".opencode", "agents", "deepveloper.md"),
  "claude-code": join(".claude", "deepveloper.md"),
};

const AGENT_CONTENTS: Record<DetectedTool, string> = {
  opencode: OPENCODE_AGENT_FRONTMATTER + SYSTEM_PROMPT,
  "claude-code": SYSTEM_PROMPT,
};

interface WriteContext {
  yes: boolean;
  summary: { written: string[]; skipped: string[] };
  confirmOverwrite?: (filePath: string) => Promise<boolean>;
  onProgress?: (filePath: string, index: number, total: number) => void | Promise<void>;
}

async function writeWithOverwriteCheck(
  filePath: string,
  content: string,
  ctx: WriteContext,
  index: number,
  total: number,
): Promise<void> {
  if (existsSync(filePath)) {
    if (ctx.yes) {
      ctx.summary.skipped.push(filePath);
      return;
    }
    if (ctx.confirmOverwrite) {
      const ok = await ctx.confirmOverwrite(filePath);
      if (!ok) {
        ctx.summary.skipped.push(filePath);
        return;
      }
    }
  }
  if (ctx.onProgress) await ctx.onProgress(filePath, index, total);
  await writeFileSafe(filePath, content);
  ctx.summary.written.push(filePath);
}

export async function installDeepveloper(
  options: InstallOptions,
): Promise<InstallSummary> {
  const { projectDir, detectedTools } = options;
  const written: string[] = [];
  const skipped: string[] = [];
  const ctx: WriteContext = {
    yes: options.yes ?? false,
    summary: { written, skipped },
    confirmOverwrite: options.confirmOverwrite,
    onProgress: options.onProgress,
  };
  const total = detectedTools.length;
  let index = 0;

  for (const tool of detectedTools) {
    index += 1;
    await writeWithOverwriteCheck(
      join(projectDir, AGENT_FILES[tool]),
      AGENT_CONTENTS[tool],
      ctx,
      index,
      total,
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
