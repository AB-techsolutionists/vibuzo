import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { mkdtempSync, existsSync, readFileSync, rmSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { ensureDir, writeFileAtomic } from "./fs.js";

let tmpDir: string;

beforeEach(() => {
  tmpDir = mkdtempSync(join(tmpdir(), "deepveloper-test-"));
});

afterEach(() => {
  rmSync(tmpDir, { recursive: true, force: true });
});

describe("ensureDir", () => {
  it("creates a directory", async () => {
    const dir = join(tmpDir, "a", "b", "c");
    await ensureDir(dir);
    expect(existsSync(dir)).toBe(true);
  });

  it("does not throw for existing directory", async () => {
    const dir = join(tmpDir, "existing");
    await ensureDir(dir);
    await expect(ensureDir(dir)).resolves.toBeUndefined();
  });
});

describe("writeFileAtomic", () => {
  it("writes a file with intermediate directories", async () => {
    const filePath = join(tmpDir, "x", "y", "test.txt");
    await writeFileAtomic(filePath, "hello");
    expect(existsSync(filePath)).toBe(true);
    expect(readFileSync(filePath, "utf-8")).toBe("hello");
  });

  it("overwrites an existing file", async () => {
    const filePath = join(tmpDir, "existing.txt");
    await writeFileAtomic(filePath, "first");
    await writeFileAtomic(filePath, "second");
    expect(readFileSync(filePath, "utf-8")).toBe("second");
  });
});
