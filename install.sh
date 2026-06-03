#!/usr/bin/env bash
#
# install.sh — Vibuzo Agentic Framework Installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --global
#
# Options:
#   --global     Install to ~/.config/opencode/ (available in ALL projects)
#   --help       Show this help message

set -euo pipefail

REPO="AB-techsolutionists/vibuzo"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"

# ─── Paths ───────────────────────────────────────────────────────────────────

if [ "${1:-}" = "--global" ]; then
    OPENCODE_DIR="${OPENCODE_INSTALL_DIR:-$HOME/.config/opencode}"
    INSTALL_TARGET="global ($OPENCODE_DIR)"
else
    OPENCODE_DIR=".opencode"
    INSTALL_TARGET="local (.opencode/)"
fi

AGENTS_DIR="$OPENCODE_DIR/agent/core"
COMMANDS_DIR="$OPENCODE_DIR/command"

# ─── Help ────────────────────────────────────────────────────────────────────

if [ "${1:-}" = "--help" ]; then
    sed -n '2,12p' "$0"
    exit 0
fi

# ─── Install ─────────────────────────────────────────────────────────────────

echo "🔧 Installing Vibuzo ($INSTALL_TARGET)..."
mkdir -p "$AGENTS_DIR" "$COMMANDS_DIR"

# Download agent files
echo "   → orchestrator.md"
curl -fsSL "$RAW_URL/agents/orchestrator.md" -o "$AGENTS_DIR/orchestrator.md"

echo "   → vibuzo.md"
curl -fsSL "$RAW_URL/agents/vibuzo.md" -o "$AGENTS_DIR/vibuzo.md"

# Download AGENTS.md to project root (if local) or to opencode dir (if global)
if [ "$INSTALL_TARGET" = "local (.opencode/)" ]; then
    echo "   → AGENTS.md (project root)"
    curl -fsSL "$RAW_URL/AGENTS.md" -o AGENTS.md
else
    echo "   → AGENTS.md (opencode dir)"
    curl -fsSL "$RAW_URL/AGENTS.md" -o "$OPENCODE_DIR/AGENTS.md"
fi

# ─── Path Rewriting (global install only) ────────────────────────────────────

if [ "$INSTALL_TARGET" != "local (.opencode/)" ]; then
    # Rewrite .opencode/ references to the actual global path
    # Works on macOS (sed -i '') and Linux/Windows (sed -i)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|\.opencode/context/|$OPENCODE_DIR/context/|g" "$AGENTS_DIR/orchestrator.md" "$AGENTS_DIR/vibuzo.md"
        sed -i '' "s|\.opencode/|$OPENCODE_DIR/|g" "$OPENCODE_DIR/AGENTS.md"
    else
        sed -i "s|\.opencode/context/|$OPENCODE_DIR/context/|g" "$AGENTS_DIR/orchestrator.md" "$AGENTS_DIR/vibuzo.md"
        sed -i "s|\.opencode/|$OPENCODE_DIR/|g" "$OPENCODE_DIR/AGENTS.md"
    fi
fi

# ─── Tool Detection ──────────────────────────────────────────────────────────

# Claude Code
if command -v claude &>/dev/null; then
    echo "   📋 Detected Claude Code — creating .claude/agents/"
    mkdir -p .claude/agents
    cp "$AGENTS_DIR/orchestrator.md" .claude/agents/orchestrator.md
    cp "$AGENTS_DIR/vibuzo.md" .claude/agents/vibuzo.md
    echo "   ✓ .claude/agents/ created"
fi

# ─── Done ────────────────────────────────────────────────────────────────────

SEP="────────────────────────────────────────────"
echo ""
echo "  ╭$SEP╮"
echo "  │"
echo "  │  ✅ Vibuzo installed successfully!"
echo "  │"
echo "  │  Location: $INSTALL_TARGET"
echo "  │  Agents:   $AGENTS_DIR/"
echo "  │"
if [ "$INSTALL_TARGET" = "local (.opencode/)" ]; then
    echo "  │  AGENTS.md is in your project root."
    echo "  │  Commit it to share with your team."
else
    echo "  │  Vibuzo is now available in ALL your projects."
    echo "  │  Run install without --global per project for AGENTS.md."
fi
echo "  │"
echo "  │  Next: opencode will pick up Orchestrator"
echo "  │  as your primary agent."
echo "  │"
echo "  ╰$SEP╯"
echo ""
