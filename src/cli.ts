#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve, relative } from "node:path";
import { intro, outro, log, spinner, confirm, note, isCancel, progress, multiselect } from "@clack/prompts";
import type { ProgressResult } from "@clack/prompts";
import chalk from "chalk";
import gradient from "gradient-string";
import type { CliOptions, DetectedTool } from "./types.js";
import { detectOpenCode, detectClaudeCode } from "./detect.js";
import { installDeepveloper, buildSkillsGuide, AGENT_FILES } from "./install.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const TOOL_LABELS: Record<DetectedTool, string> = {
  opencode: "opencode",
  "claude-code": "Claude Code",
};

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

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

async function animateProgress(bar: ProgressResult, label: string): Promise<void> {
  const steps = 10;
  bar.start(`${label} 0%`);
  for (let i = 1; i <= steps; i++) {
    await sleep(40);
    bar.advance(10, `${label} ${i * 10}%`);
  }
  bar.clear();
}

async function runInstall(projectDir: string, yes: boolean): Promise<void> {
  console.clear();
  console.log(chalk.bold(BANNER));

  const bootSpinner = spinner();
  bootSpinner.start();
  await sleep(1500);
  bootSpinner.stop();

  intro(chalk.bold("Deepveloper"));

  const detectSpinner = spinner();
  detectSpinner.start("Detecting AI coding tools...");
  await sleep(700);
  const isOpenCode = detectOpenCode(projectDir);
  const isClaudeCode = detectClaudeCode(projectDir);
  const detected: DetectedTool[] = [];
  if (isOpenCode) detected.push("opencode");
  if (isClaudeCode) detected.push("claude-code");
  detectSpinner.stop(
    detected.length === 0
      ? "No AI coding tools found"
      : `Found ${detected.length} AI coding tool${detected.length > 1 ? "s" : ""}`,
  );

  if (detected.length === 0) {
    log.warn("Deepveloper supports opencode and Claude Code, but neither was detected.");
    log.info("Install one of these tools and run deepveloper again.");
    outro(chalk.red("Installation cancelled"));
    return;
  }

  const selection = await multiselect({
    message: "Select which tools to set up",
    options: detected.map((tool) => ({
      value: tool,
      label: TOOL_LABELS[tool],
      hint: AGENT_FILES[tool],
    })),
    required: true,
    initialValues: detected,
  });
  if (isCancel(selection)) {
    log.warn("Setup cancelled.");
    outro(chalk.red("Cancelled"));
    return;
  }

  log.info(chalk.bold("Files to be written:"));
  for (const tool of selection) {
    log.success(AGENT_FILES[tool], { symbol: chalk.green("✓") });
  }

  if (!yes) {
    const proceed = await confirm({
      message: "Write these files?",
    });
    if (isCancel(proceed) || !proceed) {
      log.warn("Setup cancelled.");
      outro(chalk.red("Cancelled"));
      return;
    }
  }

  log.info(chalk.bold("Writing agent definition files:"));
  const writeBar = progress({ style: "block" });
  let result;
  try {
    result = await installDeepveloper({
      projectDir,
      detectedTools: selection,
      yes,
      onProgress: async (filePath) => {
        await animateProgress(writeBar, relative(projectDir, filePath));
      },
      confirmOverwrite: async (filePath) => {
        const display = relative(projectDir, filePath);
        const overwrite = await confirm({ message: chalk.yellow(`${display} already exists. Overwrite?`) });
        if (isCancel(overwrite)) return false;
        return overwrite;
      },
    });
  } catch (err: unknown) {
    writeBar.stop("Failed to write files");
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

  if (result.written.length > 0) {
    for (const f of result.written) {
      log.success(relative(projectDir, f), { symbol: chalk.green("✓") });
    }
  }
  if (result.skipped.length > 0) {
    for (const f of result.skipped) {
      log.info(`${chalk.dim(relative(projectDir, f))} (skipped, already exists)`);
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
