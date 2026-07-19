import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { mkdtempSync, mkdirSync, rmSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { detectOpenCode, detectClaudeCode } from "./detect.js";

let tmpDir: string;

beforeEach(() => {
  tmpDir = mkdtempSync(join(tmpdir(), "deepveloper-detect-"));
});

afterEach(() => {
  rmSync(tmpDir, { recursive: true, force: true });
});

describe("detectOpenCode", () => {
  it("returns true when .opencode/ exists in project dir", () => {
    mkdirSync(join(tmpDir, ".opencode"));
    expect(detectOpenCode(tmpDir)).toBe(true);
  });

  it("returns true when .opencode/agent exists in project dir", () => {
    mkdirSync(join(tmpDir, ".opencode", "agent"), { recursive: true });
    expect(detectOpenCode(tmpDir)).toBe(true);
  });

  it("returns false when no opencode config exists in project dir", () => {
    expect(detectOpenCode(tmpDir, tmpDir)).toBe(false);
  });

  it("returns true when opencode config exists in home dir", () => {
    mkdirSync(join(tmpDir, ".config", "opencode"), { recursive: true });
    expect(detectOpenCode(tmpDir, tmpDir)).toBe(true);
  });

  it("returns false when neither project nor home has opencode config", () => {
    expect(detectOpenCode(tmpDir, tmpDir)).toBe(false);
  });

  it("returns true when both project and home have opencode config", () => {
    mkdirSync(join(tmpDir, ".opencode"));
    mkdirSync(join(tmpDir, ".config", "opencode"), { recursive: true });
    expect(detectOpenCode(tmpDir, tmpDir)).toBe(true);
  });
});

describe("detectClaudeCode", () => {
  it("returns true when .claude/ exists in project dir", () => {
    mkdirSync(join(tmpDir, ".claude"));
    expect(detectClaudeCode(tmpDir)).toBe(true);
  });

  it("returns true when .claude/ exists in a separate home dir", () => {
    const homeDir = join(tmpDir, "homeDir");
    mkdirSync(join(homeDir, ".claude"), { recursive: true });
    expect(detectClaudeCode(tmpDir, homeDir)).toBe(true);
  });

  it("returns false when no claude config exists", () => {
    expect(detectClaudeCode(tmpDir, tmpDir)).toBe(false);
  });

  it("returns true when both project and home have claude config", () => {
    const homeDir = join(tmpDir, "homeDir");
    mkdirSync(join(tmpDir, ".claude"));
    mkdirSync(join(homeDir, ".claude"), { recursive: true });
    expect(detectClaudeCode(tmpDir, homeDir)).toBe(true);
  });
});
