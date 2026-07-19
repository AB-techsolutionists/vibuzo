#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import { stdin as input, stdout as output } from "node:process";
import { createInterface } from "node:readline/promises";
import ora from "ora";
import chalk from "chalk";
import gradient from "gradient-string";
import type { CliOptions, DetectedTool } from "./types.js";
import { detectOpenCode, detectClaudeCode } from "./detect.js";
import { installDeepveloper, installSkills } from "./install.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const BANNER_ASCII = `
  ____                     _                  _
 |  _ \\  ___  ___ ___  __| | ___ _ __ ___   | |_   ___  _ __
 | | | |/ _ \\/ __/ _ \\/ _\` |/ _ \\ '__/ _ \\  | | | / _ \\| '_ \\
 | |_| |  __/ (_|  __/ (_| |  __/ | | (_) | | | |_| (_) | |_) |
 |____/ \\___|\\___\\___|\\__,_|\\___|_|  \\___/  |_|\\__,_\\___/| .__/
                                                           |_|
`;

const BANNER = gradient(["#636363", "#d4d4d4", "#ffffff"])(BANNER_ASCII);

const POST_INSTALL_GUIDANCE = chalk.dim(`
┌──────────────────────────────────────────────────────────────┐
│  Next steps:                                                 │
│                                                              │
│  1. Open your AI coding agent (opencode or Claude Code)      │
│  2. Run the command:  /setup-matt-pocock-skills              │
│                                                              │
│  This will configure the repo's issue tracker, triage        │
│  labels, and domain documentation for the engineering        │
│  skills.                                                     │
└──────────────────────────────────────────────────────────────┘
`);

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

async function confirmInstall(): Promise<boolean> {
  const rl = createInterface({ input, output });
  const answer = await rl.question("Proceed with installation? (y/n) ");
  rl.close();
  return answer.trim().toLowerCase() === "y";
}

async function runInstall(projectDir: string, yes: boolean): Promise<void> {
  console.log(chalk.bold(BANNER));
  console.log(chalk.bold.cyan("\n═══ Deepveloper Installer ═══\n"));
  console.log("This tool will install the Deepveloper senior engineer AI agent");
  console.log("for your project. It will create agent definition files and");
  console.log("install Matt Pocock's engineering skills.\n");

  const detectSpinner = ora("Detecting AI coding tools...").start();
  const isOpenCode = detectOpenCode(projectDir);
  const isClaudeCode = detectClaudeCode(projectDir);
  const detected: DetectedTool[] = [];
  if (isOpenCode) detected.push("opencode");
  if (isClaudeCode) detected.push("claude-code");
  detectSpinner.stop();

  if (detected.length === 0) {
    console.log(chalk.yellow("No supported AI coding tools detected."));
    console.log("Deepveloper supports opencode and Claude Code.");
    console.log("Install one of these tools and run deepveloper again.");
    return;
  }

  console.log(chalk.green(`✓ Detected: ${detected.join(", ")}\n`));
  console.log(chalk.bold("The following files will be written:"));
  if (isOpenCode) {
    console.log("  - .opencode/agent/deepveloper.md");
    console.log("  - AGENTS.md");
  }
  if (isClaudeCode) {
    console.log("  - .claude/deepveloper.md");
    console.log("  - CLAUDE.md");
  }
  console.log(chalk.dim("\nMatt Pocock's engineering skills will also be installed"));
  console.log(chalk.dim("(code-review, domain-modeling, TDD, grilling, and more).\n"));

  if (!yes) {
    const ok = await confirmInstall();
    if (!ok) {
      console.log(chalk.yellow("Installation cancelled."));
      return;
    }
  }

  const writeSpinner = ora("Writing agent definition files...").start();
  let result;
  try {
    result = await installDeepveloper({
      projectDir,
      detectedTools: detected,
      yes,
      confirmOverwrite: async (filePath) => {
        writeSpinner.stop();
        const rl = createInterface({ input, output });
        const answer = await rl.question(chalk.yellow(`? ${filePath} already exists. Overwrite? (y/n) `));
        rl.close();
        writeSpinner.start();
        return answer.trim().toLowerCase() === "y";
      },
    });
  } catch (err: unknown) {
    writeSpinner.fail("Failed to write files");
    const msg = err instanceof Error ? err.message : String(err);
    console.error(chalk.red(`  Error: ${msg}`));
    if (err instanceof Error && "code" in err) {
      const code = (err as NodeJS.ErrnoException).code;
      if (code === "EACCES" || code === "EPERM") {
        console.error(chalk.red("  Permission denied. Try running with elevated permissions."));
      } else if (code === "ENOSPC") {
        console.error(chalk.red("  No space left on device. Free up disk space and try again."));
      }
    }
    return;
  }
  writeSpinner.succeed("Agent definition files written");

  if (result.written.length > 0) {
    for (const f of result.written) {
      console.log(chalk.green(`  ✓ ${f}`));
    }
  }
  if (result.skipped.length > 0) {
    for (const f of result.skipped) {
      console.log(chalk.dim(`  - ${f} (skipped, already exists)`));
    }
  }

  const skillsSpinner = ora("Installing Matt Pocock's skills...").start();
  try {
    await installSkills();
    skillsSpinner.succeed("Skills installed");
  } catch (err: unknown) {
    skillsSpinner.fail("Skills installation failed");
    const msg = err instanceof Error ? err.message : String(err);
    console.error(chalk.red(`  Error: ${msg}`));
    if (err instanceof Error && "code" in err) {
      const code = (err as NodeJS.ErrnoException).code;
      if (code === "ENOENT") {
        console.error(chalk.red("  npx not found. Ensure Node.js is installed and in your PATH."));
      }
    }
    console.log(chalk.yellow("\nFiles were written successfully but skills installation failed."));
    console.log(chalk.yellow("You can install skills manually by running:"));
    console.log(chalk.yellow("  npx skills@latest add mattpocock/skills"));
    return;
  }

  console.log(POST_INSTALL_GUIDANCE);
  console.log(chalk.bold.green("\n✓ Done. Your project is ready for the Deepveloper agent."));
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
