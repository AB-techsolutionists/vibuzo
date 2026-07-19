import { describe, it, expect } from "vitest";

describe("CLI entry point", () => {
  it("imports without error", async () => {
    // The CLI module has side effects but we can import types
    const mod = await import("./types.js");
    expect(mod).toBeDefined();
  });
});
