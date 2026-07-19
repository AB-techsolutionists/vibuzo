export interface CliOptions {
  help?: boolean;
  version?: boolean;
  yes?: boolean;
}

export type DetectedTool = "opencode" | "claude-code";

export interface InstallSummary {
  written: string[];
  skipped: string[];
  toolDetected: DetectedTool[];
}
