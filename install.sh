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

# ─── Terminal Colors ─────────────────────────────────────────────────────────

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# ─── Banner ──────────────────────────────────────────────────────────────────

printf "${CYAN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ██╗   ██╗██╗██████╗ ██╗   ██╗███████╗ ██████╗          ║
║   ██║   ██║██║██╔══██╗██║   ██║╚══███╔╝██╔═══██╗         ║
║   ██║   ██║██║██████╔╝██║   ██║  ███╔╝ ██║   ██║         ║
║   ╚██╗ ██╔╝██║██╔══██╗██║   ██║ ███╔╝  ██║   ██║         ║
║    ╚████╔╝ ██║██████╔╝╚██████╔╝███████╗╚██████╔╝         ║
║     ╚═══╝  ╚═╝╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝          ║
║                                                           ║
║               Agentic Framework                           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
printf "${NC}"

# ─── Update Mode ─────────────────────────────────────────────────────────────

if [ "$UPDATE" = true ]; then
    if [ ! -f "$VERSION_FILE" ]; then
        echo "❌ No existing Vibuzo installation found at $OPENCODE_DIR"
        echo "   Run without --update to install fresh."
        exit 1
    fi

    read -r INSTALLED_DATE INSTALLED_TIME INSTALLED_COMMIT INSTALLED_MODE < "$VERSION_FILE"

    echo ""
    printf "${YELLOW}🔍 Checking for updates...${NC}\n"
    echo ""
    printf "  ${CYAN}Current install:${NC}\n"
    echo "    Date:   $INSTALLED_DATE at $INSTALLED_TIME"
    echo "    Commit: $INSTALLED_COMMIT"
    echo "    Mode:   $INSTALLED_MODE"
    echo "    Path:   $OPENCODE_DIR"
    echo ""

    # Try to fetch latest commit SHA from GitHub API (best-effort)
    LATEST_COMMIT=$(curl -fsSL "https://api.github.com/repos/$REPO/commits/$BRANCH" 2>/dev/null \
        | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4 | cut -c1-7 || true)
    if [ -n "$LATEST_COMMIT" ]; then
        printf "  ${CYAN}Latest on origin/$BRANCH: $LATEST_COMMIT${NC}\n"
        if [ "$LATEST_COMMIT" = "$INSTALLED_COMMIT" ]; then
            echo ""
            echo "╭──────────────────────────────────────────────────────────────╮"
            echo "│                                                              │"
            printf "│              ${GREEN}✅ Vibuzo is already up to date!${NC}                 │\n"
            echo "│                                                              │"
            echo "│  Installed: $INSTALLED_DATE at $INSTALLED_TIME ($INSTALLED_COMMIT)"
            echo "│  Location:  $INSTALL_TARGET"
            echo "│                                                              │"
            echo "╰──────────────────────────────────────────────────────────────╯"
            exit 0
        else
            printf "  ${YELLOW}⬆️  Update available!${NC}\n"
        fi
    else
        printf "  ${RED}(Could not check remote — network issue or API limit)${NC}\n"
    fi
    echo ""

    # Interactive confirmation (skip if piped or non-interactive)
    if [ -t 0 ]; then
        read -p "Proceed with update? (y/N) " -r RESPONSE
        if [ "$RESPONSE" != "y" ] && [ "$RESPONSE" != "Y" ] && [ "$RESPONSE" != "yes" ] && [ "$RESPONSE" != "YES" ]; then
            printf "${YELLOW}Update cancelled.${NC}\n"
            exit 0
        fi
    else
        echo "(non-interactive shell — proceeding automatically)"
    fi

    echo ""
    printf "${YELLOW}⬆️  Updating Vibuzo ($INSTALL_TARGET)...${NC}\n"
else
    echo ""
    printf "${CYAN}🔧 Installing Vibuzo ($INSTALL_TARGET)...${NC}\n"
fi

# ─── Install / Update ────────────────────────────────────────────────────────

mkdir -p "$AGENTS_DIR" "$COMMANDS_DIR"

echo ""
printf "  ${CYAN}─── Agents ──────────────────────────────${NC}\n"
echo ""

printf "   ${GREEN}✓ vibuzo.md       (main agent)${NC}\n"
curl -fsSL "$RAW_URL/agents/vibuzo.md" -o "$AGENTS_DIR/vibuzo.md"

printf "   ${GREEN}✓ deepveloper.md  (execution specialist)${NC}\n"
curl -fsSL "$RAW_URL/agents/deepveloper.md" -o "$AGENTS_DIR/deepveloper.md"

echo ""
printf "  ${CYAN}─── Commands ────────────────────────────${NC}\n"
echo ""

printf "   ${GREEN}✓ spec.md         (feature pipeline)${NC}\n"
curl -fsSL "$RAW_URL/commands/spec.md" -o "$COMMANDS_DIR/spec.md"
printf "   ${GREEN}✓ add-context.md${NC}\n"
curl -fsSL "$RAW_URL/commands/add-context.md" -o "$COMMANDS_DIR/add-context.md"
printf "   ${GREEN}✓ context-init.md (scaffold context)${NC}\n"
curl -fsSL "$RAW_URL/commands/context-init.md" -o "$COMMANDS_DIR/context-init.md"
printf "   ${GREEN}✓ context-find.md${NC}\n"
curl -fsSL "$RAW_URL/commands/context-find.md" -o "$COMMANDS_DIR/context-find.md"
printf "   ${GREEN}✓ context-harvest.md${NC}\n"
curl -fsSL "$RAW_URL/commands/context-harvest.md" -o "$COMMANDS_DIR/context-harvest.md"
printf "   ${GREEN}✓ context-append.md${NC}\n"
curl -fsSL "$RAW_URL/commands/context-append.md" -o "$COMMANDS_DIR/context-append.md"
printf "   ${GREEN}✓ session.md${NC}\n"
curl -fsSL "$RAW_URL/commands/session.md" -o "$COMMANDS_DIR/session.md"
printf "   ${GREEN}✓ session-view.md${NC}\n"
curl -fsSL "$RAW_URL/commands/session-view.md" -o "$COMMANDS_DIR/session-view.md"
printf "   ${GREEN}✓ session-timeline.md${NC}\n"
curl -fsSL "$RAW_URL/commands/session-timeline.md" -o "$COMMANDS_DIR/session-timeline.md"

echo ""
printf "  ${CYAN}─── Project ─────────────────────────────${NC}\n"
echo ""

# Download AGENTS.md to project root (if local) or to opencode dir (if global)
if [ "$GLOBAL" = false ]; then
    if [ -f "AGENTS.md" ]; then
        echo ""
        printf "${YELLOW}  ⚠️  AGENTS.md will be overwritten${NC}\n"
        printf "  AGENTS.md is required for Vibuzo to work with 25+ AI tools.\n"
        printf "  If you have custom rules in your current AGENTS.md,\n"
        printf "  copy them before continuing — they can be re-added\n"
        printf "  as context after installation via /add-context.\n"
        echo ""
    fi
    printf "   ${GREEN}✓ AGENTS.md       (project root)${NC}\n"
    curl -fsSL "$RAW_URL/AGENTS.md" -o AGENTS.md
else
    printf "   ${GREEN}✓ AGENTS.md       (opencode dir)${NC}\n"
    curl -fsSL "$RAW_URL/AGENTS.md" -o "$OPENCODE_DIR/AGENTS.md"
fi

# ─── Path Rewriting (global install only) ────────────────────────────────────

if [ "$GLOBAL" = true ]; then
    # Rewrite .opencode/ references to the actual global path
    # Works on macOS (sed -i '') and Linux/Windows (sed -i)
    printf "   ${GREEN}✓ Path rewriting${NC}\n"
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
    echo ""
    printf "  ${CYAN}─── Integrations ─────────────────────────${NC}\n"
    echo ""
    printf "   ${GREEN}✓ Claude Code agents${NC}\n"
    mkdir -p .claude/agents
    cp "$AGENTS_DIR/vibuzo.md" .claude/agents/vibuzo.md
    cp "$AGENTS_DIR/deepveloper.md" .claude/agents/deepveloper.md
fi

# ─── Done ────────────────────────────────────────────────────────────────────

if [ "$UPDATE" = true ]; then
    ACTION="updated"
else
    ACTION="installed"
fi
echo ""
echo "╭──────────────────────────────────────────────────────────────╮"
echo "│                                                              │"
if [ "$UPDATE" = true ]; then
    printf "│              ${GREEN}✅ Vibuzo updated successfully!${NC}                 │\n"
else
    printf "│              ${GREEN}✅ Vibuzo installed successfully!${NC}                │\n"
fi
echo "│                                                              │"
echo "│  Location: $INSTALL_TARGET"
echo "│  Agents:   $AGENTS_DIR/"
echo "│                                                              │"
echo "│  ── Next Steps ──                                             │"
echo "│                                                              │"
echo "│  1. Restart opencode to pick up Vibuzo                       │"
echo "│  2. Select Vibuzo from the agent dropdown                    │"
echo "│     or create opencode.json to set as default                │"
echo "│  3. Run /context init to scaffold project memory             │"
echo "│  4. Start building with /spec [feature description]          │"
echo "│                                                              │"
echo "│  💡 Learn more: github.com/AB-techsolutionists/vibuzo        │"
echo "│                                                              │"
echo "╰──────────────────────────────────────────────────────────────╯"
echo ""
