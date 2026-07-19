import { describe, it, expect } from "vitest";

describe("CLI entry point", () => {
  it("imports without error", async () => {
    const mod = await import("../src/types.js");
    expect(mod).toBeDefined();
  });
});
