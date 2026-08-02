import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { mkdtempSync, existsSync, readFileSync, rmSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { installDeepveloper, buildSkillsGuide, OPENCODE_AGENT_FRONTMATTER } from "../src/install.js";

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

    const agentPath = join(tmpDir, ".opencode", "agents", "deepveloper.md");
    expect(existsSync(agentPath)).toBe(true);
    expect(result.written).toContain(agentPath);
  });

  it("writes correct YAML frontmatter in opencode agent file", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
    });

    const agentPath = join(tmpDir, ".opencode", "agents", "deepveloper.md");
    const content = readFileSync(agentPath, "utf-8");
    expect(content).toContain("description:");
    expect(content).toContain("mode: primary");
    expect(content).toContain("hidden: false");
    expect(content).not.toContain("color:");
    expect(content).toContain("---");
  });

  it("writes the system prompt body in opencode agent file", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
    });

    const agentPath = join(tmpDir, ".opencode", "agents", "deepveloper.md");
    const content = readFileSync(agentPath, "utf-8");
    expect(content).toContain("# Identity");
    expect(content).toContain("senior software engineer");
    expect(content).toContain("Think Before Coding");
    expect(content).toContain("Goal-Driven Execution");
  });

  it("does not create project context files", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
    });

    expect(existsSync(join(tmpDir, "AGENTS.md"))).toBe(false);
    expect(existsSync(join(tmpDir, "CLAUDE.md"))).toBe(false);
  });

  it("does not create opencode files when opencode is not detected", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: [],
    });

    const agentPath = join(tmpDir, ".opencode", "agents", "deepveloper.md");
    expect(existsSync(agentPath)).toBe(false);
  });

  it("skips existing files and reports them as skipped with --yes", async () => {
    const agentPath = join(tmpDir, ".opencode", "agents", "deepveloper.md");
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
      yes: true,
    });

    const result = await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
      yes: true,
    });

    expect(result.skipped).toContain(agentPath);
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

  it("does not create claude-code files when claude-code is not detected", async () => {
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: [],
    });

    const agentPath = join(tmpDir, ".claude", "deepveloper.md");
    expect(existsSync(agentPath)).toBe(false);
  });

  it("skips existing claude-code files with --yes", async () => {
    const agentPath = join(tmpDir, ".claude", "deepveloper.md");
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
  });

  it("creates agent files for both opencode and claude-code when both detected", async () => {
    const result = await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode", "claude-code"],
    });

    expect(existsSync(join(tmpDir, ".opencode", "agents", "deepveloper.md"))).toBe(true);
    expect(existsSync(join(tmpDir, ".claude", "deepveloper.md"))).toBe(true);
    expect(existsSync(join(tmpDir, "AGENTS.md"))).toBe(false);
    expect(existsSync(join(tmpDir, "CLAUDE.md"))).toBe(false);
    expect(result.written.length).toBe(2);
  });

  it("reports progress per file with correct index and total", async () => {
    const progress: string[] = [];
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode", "claude-code"],
      onProgress: (_filePath, index, total) => {
        progress.push(`${index}/${total}`);
      },
    });

    expect(progress).toEqual(["1/2", "2/2"]);
  });

  it("reports total matching detected tool count", async () => {
    const totals: number[] = [];
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["claude-code"],
      onProgress: (_filePath, _index, total) => {
        totals.push(total);
      },
    });

    expect(totals).toEqual([1]);
  });

  it("does not report progress for skipped files", async () => {
    const progressCalls: string[] = [];
    await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
      yes: true,
    });

    const result = await installDeepveloper({
      projectDir: tmpDir,
      detectedTools: ["opencode"],
      yes: true,
      onProgress: (filePath) => {
        progressCalls.push(filePath);
      },
    });

    expect(result.skipped.length).toBe(1);
    expect(progressCalls).toEqual([]);
  });
});

describe("buildSkillsGuide", () => {
  it("includes the skills install command", () => {
    const guide = buildSkillsGuide(["opencode"]);
    expect(guide).toContain("npx skills@latest add mattpocock/skills");
  });

  it("gives opencode instructions when opencode detected", () => {
    const guide = buildSkillsGuide(["opencode"]);
    expect(guide).toContain("In opencode");
    expect(guide).toContain("/setup-matt-pocock-skills");
  });

  it("gives claude-code instructions when claude-code detected", () => {
    const guide = buildSkillsGuide(["claude-code"]);
    expect(guide).toContain("In Claude Code");
    expect(guide).toContain("/setup-matt-pocock-skills");
  });

  it("omits opencode instructions when only claude-code detected", () => {
    const guide = buildSkillsGuide(["claude-code"]);
    expect(guide).not.toContain("Cycle to the deepveloper agent with Tab");
  });
});
