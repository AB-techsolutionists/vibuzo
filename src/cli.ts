#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import type { CliOptions, DetectedTool } from "./types.js";
import { detectOpenCode, detectClaudeCode } from "./detect.js";
import { installDeepveloper } from "./install.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function parseArgs(argv: string[]): CliOptions {
  const options: CliOptions = {};
  for (const arg of argv) {
    switch (arg) {
      case "--help":
      case "-h":
        options.help = true;
        break;
      case "--version":
      case "-v":
        options.version = true;
        break;
      case "--yes":
      case "-y":
        options.yes = true;
        break;
    }
  }
  return options;
}

function readPackageVersion(): string {
  const pkgPath = resolve(__dirname, "..", "package.json");
  const pkg = JSON.parse(readFileSync(pkgPath, "utf-8"));
  return pkg.version;
}

function printHelp(): void {
  console.log(`
deepveloper — Install the Deepveloper senior engineer AI agent

USAGE
  npx deepveloper         Run the interactive installer
  npx deepveloper --help  Show this help
  npx deepveloper --yes   Skip confirmation prompts

FLAGS
  --yes, -y   Skip all confirmation prompts
  --help, -h  Show this help message
  --version   Show the version number
`);
}

function printSummary(
  written: string[],
  skipped: string[],
): void {
  if (written.length > 0) {
    console.log("\nWritten:");
    for (const f of written) {
      console.log(`  ✓ ${f}`);
    }
  }
  if (skipped.length > 0) {
    console.log("\nSkipped (already exist):");
    for (const f of skipped) {
      console.log(`  - ${f}`);
    }
  }
}

async function runInstall(projectDir: string, yes: boolean): Promise<void> {
  const isOpenCode = detectOpenCode(projectDir);
  const isClaudeCode = detectClaudeCode(projectDir);
  const detected: DetectedTool[] = [];
  if (isOpenCode) detected.push("opencode");
  if (isClaudeCode) detected.push("claude-code");

  if (detected.length === 0) {
    console.log("No supported AI coding tools detected.");
    return;
  }

  console.log(`Detected tools: ${detected.join(", ")}`);

  if (!yes) {
    console.log("\nThe following files will be created:");
    if (isOpenCode) {
      console.log("  - .opencode/agent/deepveloper.md");
      console.log("  - AGENTS.md");
    }
    if (isClaudeCode) {
      console.log("  - .claude/deepveloper.md");
      console.log("  - CLAUDE.md");
    }
    console.log("");
  }

  const result = await installDeepveloper({
    projectDir,
    detectedTools: detected,
    yes,
  });

  printSummary(result.written, result.skipped);
  console.log("\nDone.");
}

async function main(): Promise<void> {
  const options = parseArgs(process.argv.slice(2));

  if (options.help) {
    printHelp();
    return;
  }

  if (options.version) {
    console.log(readPackageVersion());
    return;
  }

  const projectDir = process.cwd();
  await runInstall(projectDir, options.yes ?? false);
}

main();
