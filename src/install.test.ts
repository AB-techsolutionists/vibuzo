import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { mkdtempSync, existsSync, readFileSync, rmSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { installDeepveloper } from "./install.js";

let tmpDir: string;

beforeEach(() => {
  tmpDir = mkdtempSync(join(tmpdir(), "deepveloper-install-"));
});

afterEach(() => {
  rmSync(tmpDir, { recursive: true, force: true });
});

describe("installDeepveloper", () => {
  it("creates opencode agent definition when opencode is detected", async () => {
    const result = await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
    });

    const agentPath = join(tmpDir, ".opencode", "agent", "deepveloper.md");
    expect(existsSync(agentPath)).toBe(true);
    expect(result.written).toContain(agentPath);
  });

  it("writes correct YAML frontmatter in opencode agent file", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
    });

    const agentPath = join(tmpDir, ".opencode", "agent", "deepveloper.md");
    const content = readFileSync(agentPath, "utf-8");
    expect(content).toContain("mode: primary");
    expect(content).toContain("hidden: false");
    expect(content).toContain("color: emerald");
    expect(content).toContain("---");
  });

  it("writes the system prompt body in opencode agent file", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
    });

    const agentPath = join(tmpDir, ".opencode", "agent", "deepveloper.md");
    const content = readFileSync(agentPath, "utf-8");
    expect(content).toContain("# Identity");
    expect(content).toContain("senior software engineer");
    expect(content).toContain("Think Before Coding");
    expect(content).toContain("Goal-Driven Execution");
  });

  it("creates AGENTS.md skeleton at project root", async () => {
    const result = await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
    });

    const agentsPath = join(tmpDir, "AGENTS.md");
    expect(existsSync(agentsPath)).toBe(true);
    expect(result.written).toContain(agentsPath);
  });

  it("writes AGENTS.md with project context skeleton", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
    });

    const agentsPath = join(tmpDir, "AGENTS.md");
    const content = readFileSync(agentsPath, "utf-8");
    expect(content).toContain("Project");
    expect(content.length).toBeGreaterThan(0);
  });

  it("does not create opencode files when opencode is not detected", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: [],
    });

    const agentPath = join(tmpDir, ".opencode", "agent", "deepveloper.md");
    expect(existsSync(agentPath)).toBe(false);
  });

  it("does not create AGENTS.md when no tools are detected", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: [],
    });

    const agentsPath = join(tmpDir, "AGENTS.md");
    expect(existsSync(agentsPath)).toBe(false);
  });

  it("skips existing files and reports them as skipped with --yes", async () => {
    const agentPath = join(tmpDir, ".opencode", "agent", "deepveloper.md");
    const agentsPath = join(tmpDir, "AGENTS.md");
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
      yes: true,
    });

    // Run again with --yes
    const result = await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
      yes: true,
    });

    expect(result.skipped).toContain(agentPath);
    expect(result.skipped).toContain(agentsPath);
  });

  it("returns correct summary of written files", async () => {
    const result = await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
    });

    expect(result.written.length).toBeGreaterThan(0);
    expect(result.skipped.length).toBe(0);
    expect(result.toolDetected).toEqual(["opencode"]);
  });
});
