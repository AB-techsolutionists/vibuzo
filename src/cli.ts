#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import { intro, outro, log, spinner, confirm, note, isCancel } from "@clack/prompts";
import chalk from "chalk";
import gradient from "gradient-string";
import type { CliOptions, DetectedTool } from "./types.js";
import { detectOpenCode, detectClaudeCode } from "./detect.js";
import { installDeepveloper, buildSkillsGuide } from "./install.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const BANNER_ASCII = `
██████╗ ███████╗███████╗██████╗ ██╗   ██╗███████╗██╗      ██████╗ ██████╗ ███████╗██████╗
██╔══██╗██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██║     ██╔═══██╗██╔══██╗██╔════╝██╔══██╗
██║  ██║█████╗  █████╗  ██████╔╝██║   ██║█████╗  ██║     ██║   ██║██████╔╝█████╗  ██████╔╝
██║  ██║██╔══╝  ██╔══╝  ██╔═══╝ ╚██╗ ██╔╝██╔══╝  ██║     ██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗
██████╔╝███████╗███████╗██║      ╚████╔╝ ███████╗███████╗╚██████╔╝██║     ███████╗██║  ██║
╚═════╝ ╚══════╝╚══════╝╚═╝       ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝
`;

const BANNER = gradient(["#636363", "#d4d4d4", "#ffffff"])(BANNER_ASCII);

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
  npx deepveloper@latest         Run the interactive installer
  npx deepveloper@latest --help  Show this help
  npx deepveloper@latest --yes   Skip confirmation prompts

FLAGS
  --yes, -y   Skip all confirmation prompts
  --help, -h  Show this help message
  --version   Show the version number
`);
}

async function runInstall(projectDir: string, yes: boolean): Promise<void> {
  console.log(chalk.bold(BANNER));
  intro(chalk.bold("Deepveloper"));

  log.info(chalk.bold("What is Deepveloper?"));
  log.message(
    "Deepveloper installs the Senior Engineer AI agent into this project — a\n" +
    "system prompt built on Karpathy's four principles (Think Before Coding,\n" +
    "Simplicity First, Surgical Changes, Goal-Driven Execution).",
  );

  log.info(chalk.bold("What will happen:"));
  log.message([
    "• Detect your AI coding tools (opencode, Claude Code)",
    "• Write the deepveloper agent definition for each tool you use",
    "• Show you how to install Matt Pocock's engineering skills yourself",
  ]);

  if (!yes) {
    const proceed = await confirm({
      message: "Set up Deepveloper in this project?",
    });
    if (isCancel(proceed) || !proceed) {
      log.warn("Setup cancelled.");
      outro(chalk.red("Cancelled"));
      return;
    }
  }

  const detectSpinner = spinner();
  detectSpinner.start("Detecting AI coding tools...");
  const isOpenCode = detectOpenCode(projectDir);
  const isClaudeCode = detectClaudeCode(projectDir);
  const detected: DetectedTool[] = [];
  if (isOpenCode) detected.push("opencode");
  if (isClaudeCode) detected.push("claude-code");
  detectSpinner.stop(detected.length > 0 ? "Tools detected" : "No tools found");

  if (detected.length === 0) {
    log.warn("No supported AI coding tools detected. Deepveloper supports opencode and Claude Code.");
    log.info("Install one of these tools and run deepveloper again.");
    outro(chalk.red("Installation cancelled"));
    return;
  }

  log.success(`Detected: ${detected.join(", ")}`);

  const writeSpinner = spinner();
  writeSpinner.start("Writing agent definition files...");
  let result;
  try {
    result = await installDeepveloper({
      projectDir,
      detectedTools: detected,
      yes,
      confirmOverwrite: async (filePath) => {
        writeSpinner.stop("File exists");
        const overwrite = await confirm({ message: chalk.yellow(`${filePath} already exists. Overwrite?`) });
        writeSpinner.start("Writing agent definition files...");
        if (isCancel(overwrite)) return false;
        return overwrite;
      },
    });
  } catch (err: unknown) {
    writeSpinner.stop("Failed to write files");
    const msg = err instanceof Error ? err.message : String(err);
    log.error(`  Error: ${msg}`);
    if (err instanceof Error && "code" in err) {
      const code = (err as NodeJS.ErrnoException).code;
      if (code === "EACCES" || code === "EPERM") {
        log.error("  Permission denied. Try running with elevated permissions.");
      } else if (code === "ENOSPC") {
        log.error("  No space left on device. Free up disk space and try again.");
      }
    }
    outro(chalk.red("Installation failed"));
    return;
  }
  writeSpinner.stop("Agent definition files written");

  if (result.written.length > 0) {
    for (const f of result.written) {
      log.success(f);
    }
  }
  if (result.skipped.length > 0) {
    for (const f of result.skipped) {
      log.info(`${chalk.dim(f)} (skipped, already exists)`);
    }
  }

  note(buildSkillsGuide(detected), "Next steps");
  outro(chalk.bold.green("Done. Your project is ready for the Deepveloper agent."));
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
