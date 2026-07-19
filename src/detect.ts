import { existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

export function detectOpenCode(projectDir: string, home?: string): boolean {
  const projectConfig = join(projectDir, ".opencode");
  const homeConfig = join(home ?? homedir(), ".config", "opencode");
  return existsSync(projectConfig) || existsSync(homeConfig);
}
