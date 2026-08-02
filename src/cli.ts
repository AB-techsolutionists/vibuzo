#!/usr/bin/env node

import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve, relative, join } from "node:path";
import { intro, outro, log, spinner, confirm, note, isCancel, multiselect } from "@clack/prompts";
import type { SpinnerResult } from "@clack/prompts";
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

const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

function makeSpinner(): SpinnerResult {
  return spinner({
    frames: SPINNER_FRAMES,
    delay: 80,
    styleFrame: (frame) => chalk.cyan(frame),
  });
}

async function animateProgress(label: string): Promise<void> {
  const width = 18;
  const steps = 10;
  const maxLabel = Math.max(0, (process.stdout.columns ?? 80) - 34);
  const shortLabel = label.length > maxLabel ? `${label.slice(0, maxLabel - 1)}…` : label;
  for (let i = 0; i <= steps; i++) {
    const filled = Math.round((i / steps) * width);
    const bar = chalk.whiteBright("█".repeat(filled)) + chalk.dim("░".repeat(width - filled));
    process.stdout.write(`\r${bar} ${chalk.bold(`${i * 10}%`)} ${shortLabel}`);
    await sleep(50);
  }
  process.stdout.write("\r\x1b[K");
}

async function runInstall(projectDir: string, yes: boolean): Promise<void> {
  console.clear();
  console.log(chalk.bold(BANNER));

  const bootSpinner = makeSpinner();
  bootSpinner.start();
  await sleep(1500);
  bootSpinner.stop();
  process.stdout.write("\r\x1b[K");

  intro(chalk.bold("Deepveloper"));

  const detectSpinner = makeSpinner();
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

  let setupTools: DetectedTool[];
  if (yes) {
    setupTools = detected;
  } else {
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
    setupTools = selection;
  }

  const existingFiles = setupTools
    .map((tool) => join(projectDir, AGENT_FILES[tool]))
    .filter((filePath) => existsSync(filePath));

  let overwriteExisting = false;
  if (existingFiles.length > 0) {
    log.warn(chalk.bold("Previous installation found"));
    for (const f of existingFiles) {
      log.message(`  ${chalk.dim(relative(projectDir, f))}`);
    }
    if (!yes) {
      const overwrite = await confirm({
        message:
          existingFiles.length === 1
            ? `${relative(projectDir, existingFiles[0])} — overwrite it?`
            : `Overwrite these ${existingFiles.length} existing files?`,
      });
      if (isCancel(overwrite)) {
        log.warn("Setup cancelled.");
        outro(chalk.red("Cancelled"));
        return;
      }
      overwriteExisting = overwrite === true;
    }
  }

  log.info(chalk.bold("Writing agent definition files:"));
  let result;
  try {
    result = await installDeepveloper({
      projectDir,
      detectedTools: setupTools,
      yes,
      onProgress: async (filePath) => {
        await animateProgress(relative(projectDir, filePath));
      },
      confirmOverwrite: existingFiles.length > 0 && !yes ? async () => overwriteExisting : undefined,
    });
  } catch (err: unknown) {
    process.stdout.write("\r\x1b[K");
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
