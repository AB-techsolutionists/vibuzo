#!/usr/bin/env bash
#
# install.sh — Vibuzo Agentic Framework Installer
#
# Installs Vibuzo (main), Deepveloper (subtask), /spec pipeline, and active commands.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --global
#   curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --update
#
# Options:
#   --global     Install to ~/.config/opencode/ (available in ALL projects)
#   --update     Update existing installation (shows version info, prompts confirmation before overwriting)
#   --help       Show this help message

set -euo pipefail

REPO="AB-techsolutionists/vibuzo"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"

# ─── Arg Parsing ─────────────────────────────────────────────────────────────

GLOBAL=false
UPDATE=false

for arg in "$@"; do
    case "$arg" in
        --global) GLOBAL=true ;;
        --update) UPDATE=true ;;
        --help)
            sed -n '2,14p' "$0"
            exit 0
            ;;
    esac
done

# ─── Paths ───────────────────────────────────────────────────────────────────

if [ "$GLOBAL" = true ]; then
    OPENCODE_DIR="${OPENCODE_INSTALL_DIR:-$HOME/.config/opencode}"
    INSTALL_TARGET="global ($OPENCODE_DIR)"
else
    OPENCODE_DIR=".opencode"
    INSTALL_TARGET="local (.opencode/)"
fi

AGENTS_DIR="$OPENCODE_DIR/agent/core"
COMMANDS_DIR="$OPENCODE_DIR/commands"
VERSION_FILE="$OPENCODE_DIR/.vibuzo-version"

# ─── Update Mode ─────────────────────────────────────────────────────────────

if [ "$UPDATE" = true ]; then
    if [ ! -f "$VERSION_FILE" ]; then
        echo "❌ No existing Vibuzo installation found at $OPENCODE_DIR"
        echo "   Run without --update to install fresh."
        exit 1
    fi

    read -r INSTALLED_DATE INSTALLED_TIME INSTALLED_COMMIT INSTALLED_MODE < "$VERSION_FILE"

    echo "🔍 Checking for updates..."
    echo ""
    echo "  Current install:"
    echo "    Date:   $INSTALLED_DATE at $INSTALLED_TIME"
    echo "    Commit: $INSTALLED_COMMIT"
    echo "    Mode:   $INSTALLED_MODE"
    echo "    Path:   $OPENCODE_DIR"
    echo ""

    # Try to fetch latest commit SHA from GitHub API (best-effort)
    LATEST_COMMIT=$(curl -fsSL "https://api.github.com/repos/$REPO/commits/$BRANCH" 2>/dev/null \
        | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4 | cut -c1-7 || true)
    if [ -n "$LATEST_COMMIT" ]; then
        echo "  Latest on origin/$BRANCH: $LATEST_COMMIT"
        if [ "$LATEST_COMMIT" = "$INSTALLED_COMMIT" ]; then
            echo "  ✅ Already up to date!"
        else
            echo "  ⬆️  Update available!"
        fi
    else
        echo "  (Could not check remote — network issue or API limit)"
    fi
    echo ""

    # Interactive confirmation (skip if piped or non-interactive)
    if [ -t 0 ]; then
        read -p "Proceed with update? (y/N) " -r RESPONSE
        if [ "$RESPONSE" != "y" ] && [ "$RESPONSE" != "Y" ] && [ "$RESPONSE" != "yes" ] && [ "$RESPONSE" != "YES" ]; then
            echo "Update cancelled."
            exit 0
        fi
    else
        echo "(non-interactive shell — proceeding automatically)"
    fi

    echo "⬆️  Updating Vibuzo ($INSTALL_TARGET)..."
else
    echo "🔧 Installing Vibuzo ($INSTALL_TARGET)..."
fi

# ─── Install / Update ────────────────────────────────────────────────────────

mkdir -p "$AGENTS_DIR" "$COMMANDS_DIR"

# Download agent files
echo "   → vibuzo.md (main agent)"
curl -fsSL "$RAW_URL/agents/vibuzo.md" -o "$AGENTS_DIR/vibuzo.md"

echo "   → deepveloper.md (execution specialist)"
curl -fsSL "$RAW_URL/agents/deepveloper.md" -o "$AGENTS_DIR/deepveloper.md"

# Download command files
echo "   → spec.md (feature pipeline)"
curl -fsSL "$RAW_URL/commands/spec.md" -o "$COMMANDS_DIR/spec.md"
echo "   → add-context.md"
curl -fsSL "$RAW_URL/commands/add-context.md" -o "$COMMANDS_DIR/add-context.md"
echo "   → context-init.md (scaffold context)"
curl -fsSL "$RAW_URL/commands/context-init.md" -o "$COMMANDS_DIR/context-init.md"
echo "   → context-find.md (search context)"
curl -fsSL "$RAW_URL/commands/context-find.md" -o "$COMMANDS_DIR/context-find.md"
echo "   → context-harvest.md (promote sessions)"
curl -fsSL "$RAW_URL/commands/context-harvest.md" -o "$COMMANDS_DIR/context-harvest.md"
echo "   → context-append.md (scan conversation)"
curl -fsSL "$RAW_URL/commands/context-append.md" -o "$COMMANDS_DIR/context-append.md"
echo "   → session.md"
curl -fsSL "$RAW_URL/commands/session.md" -o "$COMMANDS_DIR/session.md"
echo "   → session-view.md (browse sessions)"
curl -fsSL "$RAW_URL/commands/session-view.md" -o "$COMMANDS_DIR/session-view.md"
echo "   → session-timeline.md (session timeline)"
curl -fsSL "$RAW_URL/commands/session-timeline.md" -o "$COMMANDS_DIR/session-timeline.md"

# Download AGENTS.md to project root (if local) or to opencode dir (if global)
if [ "$GLOBAL" = false ]; then
    echo "   → AGENTS.md (project root)"
    curl -fsSL "$RAW_URL/AGENTS.md" -o AGENTS.md
else
    echo "   → AGENTS.md (opencode dir)"
    curl -fsSL "$RAW_URL/AGENTS.md" -o "$OPENCODE_DIR/AGENTS.md"
fi

# ─── Path Rewriting (global install only) ────────────────────────────────────

if [ "$GLOBAL" = true ]; then
    # Rewrite .opencode/ references to the actual global path
    # Works on macOS (sed -i '') and Linux/Windows (sed -i)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|\.opencode/context/|$OPENCODE_DIR/context/|g" "$AGENTS_DIR/vibuzo.md" "$AGENTS_DIR/deepveloper.md"
        sed -i '' "s|\.opencode/|$OPENCODE_DIR/|g" "$OPENCODE_DIR/AGENTS.md"
    else
        sed -i "s|\.opencode/context/|$OPENCODE_DIR/context/|g" "$AGENTS_DIR/vibuzo.md" "$AGENTS_DIR/deepveloper.md"
        sed -i "s|\.opencode/|$OPENCODE_DIR/|g" "$OPENCODE_DIR/AGENTS.md"
    fi
fi

# ─── Write Version File ──────────────────────────────────────────────────────

NOW=$(date '+%Y-%m-%d %H:%M')
if [ "$GLOBAL" = true ]; then
    MODE="global"
else
    MODE="local"
fi
# Try to get the latest commit SHA (best-effort)
SHA=$(curl -fsSL "https://api.github.com/repos/$REPO/commits/$BRANCH" 2>/dev/null \
    | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4 | cut -c1-7 || true)
if [ -z "$SHA" ]; then
    SHA="unknown"
fi
echo "$NOW $SHA $MODE" > "$VERSION_FILE"

# ─── Tool Detection ──────────────────────────────────────────────────────────

# Claude Code
if command -v claude &>/dev/null; then
    echo "   📋 Detected Claude Code — creating .claude/agents/"
    mkdir -p .claude/agents
    cp "$AGENTS_DIR/vibuzo.md" .claude/agents/vibuzo.md
    cp "$AGENTS_DIR/deepveloper.md" .claude/agents/deepveloper.md
    echo "   ✓ .claude/agents/ created"
fi

# ─── Done ────────────────────────────────────────────────────────────────────

if [ "$UPDATE" = true ]; then
    ACTION="updated"
else
    ACTION="installed"
fi
SEP="────────────────────────────────────────────"
echo ""
echo "  ╭$SEP╮"
echo "  │"
echo "  │  ✅ Vibuzo $ACTION successfully!"
echo "  │"
echo "  │  Location: $INSTALL_TARGET"
echo "  │  Agents:   $AGENTS_DIR/"
echo "  │"
if [ "$GLOBAL" = false ]; then
    echo "  │  AGENTS.md is in your project root."
    echo "  │  Commit it to share with your team."
else
    echo "  │  Vibuzo is now available in ALL your projects."
    echo "  │  Run install without --global per project for AGENTS.md."
fi
echo "  │"
echo "  │  Next: opencode will pick up Vibuzo"
echo "  │  as your primary agent. Use /spec to start a feature pipeline."
echo "  │"
echo "  ╰$SEP╯"
echo ""
