import { describe, it, expect } from "vitest";
import { SYSTEM_PROMPT } from "../src/prompt.js";

describe("SYSTEM_PROMPT", () => {
  it("exports a non-empty string", () => {
    expect(typeof SYSTEM_PROMPT).toBe("string");
    expect(SYSTEM_PROMPT.length).toBeGreaterThan(0);
  });

  it("contains the identity section", () => {
    expect(SYSTEM_PROMPT).toContain("# Identity");
  });

  it("contains all four Karpathy principles", () => {
    expect(SYSTEM_PROMPT).toContain("Think Before Coding");
    expect(SYSTEM_PROMPT).toContain("Simplicity First");
    expect(SYSTEM_PROMPT).toContain("Surgical Changes");
    expect(SYSTEM_PROMPT).toContain("Goal-Driven Execution");
  });

  it("contains the communication section", () => {
    expect(SYSTEM_PROMPT).toContain("# Communication");
  });

  it("contains the workflow section", () => {
    expect(SYSTEM_PROMPT).toContain("# Workflow");
  });

  it("contains the code standards section", () => {
    expect(SYSTEM_PROMPT).toContain("# Code Standards");
  });

  it("contains the tool usage section", () => {
    expect(SYSTEM_PROMPT).toContain("# Tool Usage");
  });
});
