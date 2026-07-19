import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { mkdtempSync, existsSync, readFileSync, rmSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { EventEmitter } from "node:events";
import type { ChildProcess } from "node:child_process";
import { installDeepveloper, installSkills } from "./install.js";

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

  it("creates claude-code agent definition when claude-code is detected", async () => {
    const result = await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["claude-code"],
    });

    const agentPath = join(tmpDir, ".claude", "deepveloper.md");
    expect(existsSync(agentPath)).toBe(true);
    expect(result.written).toContain(agentPath);
  });

  it("writes raw prompt body (no frontmatter) in claude-code agent file", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["claude-code"],
    });

    const agentPath = join(tmpDir, ".claude", "deepveloper.md");
    const content = readFileSync(agentPath, "utf-8");
    expect(content).toContain("# Identity");
    expect(content).toContain("senior software engineer");
    expect(content).not.toContain("mode: primary");
    expect(content).not.toContain("---");
  });

  it("creates CLAUDE.md skeleton at project root for claude-code detection", async () => {
    const result = await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["claude-code"],
    });

    const claudePath = join(tmpDir, "CLAUDE.md");
    expect(existsSync(claudePath)).toBe(true);
    expect(result.written).toContain(claudePath);
  });

  it("writes CLAUDE.md with project context skeleton", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["claude-code"],
    });

    const claudePath = join(tmpDir, "CLAUDE.md");
    const content = readFileSync(claudePath, "utf-8");
    expect(content).toContain("Project Context");
    expect(content.length).toBeGreaterThan(0);
  });

  it("does not create claude-code files when claude-code is not detected", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: [],
    });

    const agentPath = join(tmpDir, ".claude", "deepveloper.md");
    expect(existsSync(agentPath)).toBe(false);
    expect(existsSync(join(tmpDir, "CLAUDE.md"))).toBe(false);
  });

  it("skips existing claude-code files with --yes", async () => {
    const agentPath = join(tmpDir, ".claude", "deepveloper.md");
    const claudePath = join(tmpDir, "CLAUDE.md");
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["claude-code"],
      yes: true,
    });

    const result = await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["claude-code"],
      yes: true,
    });

    expect(result.skipped).toContain(agentPath);
    expect(result.skipped).toContain(claudePath);
  });

  it("creates files for both opencode and claude-code when both detected", async () => {
    const result = await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode", "claude-code"],
    });

    expect(existsSync(join(tmpDir, ".opencode", "agent", "deepveloper.md"))).toBe(true);
    expect(existsSync(join(tmpDir, ".claude", "deepveloper.md"))).toBe(true);
    expect(existsSync(join(tmpDir, "AGENTS.md"))).toBe(true);
    expect(existsSync(join(tmpDir, "CLAUDE.md"))).toBe(true);
    expect(result.written.length).toBe(4);
  });
});

function mockChildProcess(): ChildProcess {
  const ee = new EventEmitter() as unknown as ChildProcess;
  return ee;
}

describe("installSkills", () => {
  it("calls npx skills@latest add mattpocock/skills", async () => {
    const spawn = vi.fn(() => {
      const cp = mockChildProcess();
      setTimeout(() => cp.emit("close", 0));
      return cp;
    });

    await installSkills(spawn);

    expect(spawn).toHaveBeenCalledWith("npx", [
      "skills@latest",
      "add",
      "mattpocock/skills",
    ], { stdio: "inherit", shell: true });
  });

  it("resolves on exit code 0", async () => {
    const spawn = vi.fn(() => {
      const cp = mockChildProcess();
      setTimeout(() => cp.emit("close", 0));
      return cp;
    });

    await expect(installSkills(spawn)).resolves.toBeUndefined();
  });

  it("rejects on non-zero exit code", async () => {
    const spawn = vi.fn(() => {
      const cp = mockChildProcess();
      setTimeout(() => cp.emit("close", 1));
      return cp;
    });

    await expect(installSkills(spawn)).rejects.toThrow(
      "npx skills exited with code 1",
    );
  });

  it("rejects on spawn error", async () => {
    const spawn = vi.fn(() => {
      const cp = mockChildProcess();
      setTimeout(() => cp.emit("error", new Error("ENOENT")), 0);
      return cp;
    });

    await expect(installSkills(spawn)).rejects.toThrow("ENOENT");
  });
});
