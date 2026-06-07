#!/usr/bin/env bash
#
# install.sh — Vibuzo Agentic Framework Installer
#
# Installs Vibuzo (main), Deepveloper (subtask), /spec pipeline, and active commands.
#
# Version: ${SCRIPT_VERSION}
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

# ─── Version ─────────────────────────────────────────────────────────────────

SCRIPT_VERSION=$(curl -fsSL "$RAW_URL/VERSION" 2>/dev/null || echo "unknown")

# ─── File Arrays ──────────────────────────────────────────────────────────────

AGENT_FILES=(
    "vibuzo.md"
    "deepveloper.md"
)

COMMAND_FILES=(
    "spec" "add-context" "context-init" "context-find"
    "context-harvest" "context-append" "session"
    "session-view" "session-timeline"
)

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

# ─── Section Renderer ────────────────────────────────────────────────────────

print_section() {
    local name="$1"
    shift
    local items=("$@")
    local count=${#items[@]}

    # Section header with count: "  ── Name (N) ──────────────────────"
    local header="  ── $name ($count) "
    local pad=$((54 - ${#header}))
    printf "${CYAN}%s${NC}" "$header"
    for ((j=0; j<pad; j++)); do printf '─'; done
    printf "\n"

    # Grouped items with wrapping at 4 items
    local line="  ✓ "
    local i=0
    for item in "${items[@]}"; do
        if [ $i -gt 0 ] && [ $((i % 4)) -eq 0 ]; then
            line="${line%, }"
            printf "${GREEN}%s${NC}\n" "$line"
            line="    "
        fi
        line="${line}${item}, "
        i=$((i + 1))
    done
    if [ "$line" != "  ✓ " ]; then
        line="${line%, }"
        printf "${GREEN}%s${NC}\n" "$line"
    fi
}

# ─── Box Renderer ────────────────────────────────────────────────────────────

print_box() {
    local title="$1"
    shift
    local lines=("$@")
    local max_len=0

    for line in "${lines[@]}"; do
        if [ ${#line} -gt $max_len ]; then
            max_len=${#line}
        fi
    done

    # Total width: left border + space + content + space + right border
    local total=$((max_len + 4))
    
    # Title section with spaces
    local title_section=" $title "
    local title_len=${#title_section}
    
    # Dashes: (total - 2 corners - title) split evenly
    local dash_space=$((total - 2 - title_len))
    local left_dashes=$((dash_space / 2))
    local right_dashes=$((dash_space - left_dashes))
    
    # Top border
    printf "${CYAN}╭"
    for ((i=0; i<left_dashes; i++)); do printf "─"; done
    printf "%s" "$title_section"
    for ((i=0; i<right_dashes; i++)); do printf "─"; done
    printf "╮${NC}\n"

    # Content lines
    for line in "${lines[@]}"; do
        local pad_len=$((max_len - ${#line}))
        printf "${CYAN}│${NC} %s" "$line"
        for ((i=0; i<pad_len; i++)); do printf " "; done
        printf " ${CYAN}│${NC}\n"
    done

    # Bottom border
    printf "${CYAN}╰"
    for ((i=0; i<total - 2; i++)); do printf "─"; done
    printf "╯${NC}\n"
}

# ─── Banner ──────────────────────────────────────────────────────────────────

printf "${CYAN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ██╗   ██╗██╗██████╗ ██╗   ██╗███████╗ ██████╗           ║
║   ██║   ██║██║██╔══██╗██║   ██║╚══███╔╝██╔═══██╗          ║
║   ██║   ██║██║██████╔╝██║   ██║  ███╔╝ ██║   ██║          ║
║   ╚██╗ ██╔╝██║██╔══██╗██║   ██║ ███╔╝  ██║   ██║          ║
║    ╚████╔╝ ██║██████╔╝╚██████╔╝███████╗╚██████╔╝          ║
║     ╚═══╝  ╚═╝╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝           ║
║                                                           ║
║           Agentic Framework for Ai coding                 ║
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

    read -r CURRENT_VERSION_LINE < "$VERSION_FILE"
    # Format: 0.x.x | yyyy-MM-dd HH:mm mode
    VERSION="${CURRENT_VERSION_LINE%% | *}"
    REST="${CURRENT_VERSION_LINE#* | }"
    read -r INSTALLED_DATE INSTALLED_TIME INSTALLED_MODE <<< "$REST"

    # Format date for display: "Jun 07 at 00:42"
    MONTH_NUM="${INSTALLED_DATE#*-}"; MONTH_NUM="${MONTH_NUM%%-*}"
    DAY="${INSTALLED_DATE##*-}"
    case $MONTH_NUM in
        01) MONTH="Jan" ;; 02) MONTH="Feb" ;; 03) MONTH="Mar" ;;
        04) MONTH="Apr" ;; 05) MONTH="May" ;; 06) MONTH="Jun" ;;
        07) MONTH="Jul" ;; 08) MONTH="Aug" ;; 09) MONTH="Sep" ;;
        10) MONTH="Oct" ;; 11) MONTH="Nov" ;; 12) MONTH="Dec" ;;
    esac
    DAY=$((10#$DAY))
    INSTALLED_FULL="$MONTH $DAY at $INSTALLED_TIME"

    # Compare versions
    UP_TO_DATE=false
    if [ "$VERSION" = "$SCRIPT_VERSION" ]; then
        STATUS="✅ Up to date"
        UP_TO_DATE=true
    elif [ "$SCRIPT_VERSION" != "unknown" ]; then
        STATUS="⬆️ Update available"
    else
        STATUS="⚠️ Could not check"
    fi

    # Build and display the update check box
    BOX_LINES=()
    BOX_LINES+=("Current:  $VERSION")
    BOX_LINES+=("Latest:   $SCRIPT_VERSION")
    BOX_LINES+=("Status:   $STATUS")
    BOX_LINES+=("")
    BOX_LINES+=("Installed: $INSTALLED_FULL")
    BOX_LINES+=("Location:  $OPENCODE_DIR")

    print_box "Vibuzo Update Check" "${BOX_LINES[@]}"

    if [ "$UP_TO_DATE" = true ]; then
        exit 0
    fi

    # Interactive confirmation (skip if piped or non-interactive)
    if [ -t 0 ]; then
        printf "\nProceed with update? (y/N): "
        read -r RESPONSE
        if [ "$RESPONSE" != "y" ] && [ "$RESPONSE" != "Y" ] && [ "$RESPONSE" != "yes" ] && [ "$RESPONSE" != "YES" ]; then
            printf "${YELLOW}Update cancelled.${NC}\n"
            exit 0
        fi
    else
        echo ""
        echo "(non-interactive shell — proceeding automatically)"
    fi

    echo ""
    printf "${YELLOW}⬆️  Updating Vibuzo ${SCRIPT_VERSION} ($INSTALL_TARGET)...${NC}\n"
else
    echo ""
    printf "${CYAN}🔧 Installing Vibuzo ${SCRIPT_VERSION} ($INSTALL_TARGET)...${NC}\n"
fi

# ─── Install / Update ────────────────────────────────────────────────────────

mkdir -p "$AGENTS_DIR" "$COMMANDS_DIR"

echo ""
print_section "Agents" "${AGENT_FILES[@]}"

for f in "${AGENT_FILES[@]}"; do
    curl -fsSL "$RAW_URL/agents/$f" -o "$AGENTS_DIR/$f"
done

echo ""
print_section "Commands" "${COMMAND_FILES[@]}"

for f in "${COMMAND_FILES[@]}"; do
    curl -fsSL "$RAW_URL/commands/$f.md" -o "$COMMANDS_DIR/$f.md"
done

echo ""
printf "  ${CYAN}─── Project ─────────────────────────────${NC}\n"

# Download AGENTS.md to project root (if local) or to opencode dir (if global)
if [ "$GLOBAL" = false ]; then
    # ─── Check AGENTS.md status ────────────────────────────────────
    EXISTING_CONTENT=""
    USER_RULES=""
    AGENTS_STATUS="fresh copy"
    if [ -f "AGENTS.md" ]; then
        if grep -q "PASTE YOUR CUSTOM RULES BELOW THIS LINE" AGENTS.md 2>/dev/null; then
            # Vibuzo file — save content below marker (user's custom rules)
            USER_RULES=$(awk '/PASTE YOUR CUSTOM RULES BELOW THIS LINE/{found=1; next} found' AGENTS.md 2>/dev/null)
            if [ -n "$USER_RULES" ]; then
                AGENTS_STATUS="with custom rules preserved"
            fi
        else
            # User's own AGENTS.md — save entire content to prepend
            EXISTING_CONTENT=$(cat AGENTS.md)
            AGENTS_STATUS="your content preserved at top"
        fi
    fi

    printf "  ${GREEN}✓ AGENTS.md ($AGENTS_STATUS)${NC}\n"

    if [ -t 0 ]; then
        printf "\nProceed with AGENTS.md? (y/N): "
        read -r RESPONSE
        if [ "$RESPONSE" != "y" ] && [ "$RESPONSE" != "Y" ] && [ "$RESPONSE" != "yes" ] && [ "$RESPONSE" != "YES" ]; then
            printf "${YELLOW}AGENTS.md skipped.${NC}\n"
            return
        fi
    else
        echo "(non-interactive shell — proceeding automatically)"
    fi

    curl -fsSL "$RAW_URL/AGENTS.md" -o AGENTS.md
    if [ -n "$EXISTING_CONTENT" ]; then
        # User had their own AGENTS.md — prepend it above Vibuzo content
        VIBUZO_CONTENT=$(cat AGENTS.md)
        printf "%s\n\n---\n\n%s" "$EXISTING_CONTENT" "$VIBUZO_CONTENT" > AGENTS.md
    elif [ -n "$USER_RULES" ]; then
        # Vibuzo file with custom rules below marker — re-append them
        printf "\n%s" "$USER_RULES" >> AGENTS.md
    fi
else
    printf "  ${GREEN}✓ AGENTS.md (fresh copy)${NC}\n"
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
echo "${SCRIPT_VERSION} | $NOWhen
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
print_box "✅ Vibuzo ${SCRIPT_VERSION} ${ACTION} successfully!" \
    "Location:  $INSTALL_TARGET" \
    "" \
    "── Next Steps ──" \
    "1. Restart opencode → select Vibuzo" \
    "2. Run /context init to scaffold project memory" \
    "3. Start building with /spec [feature description]" \
    "💡 github.com/AB-techsolutionists/vibuzo"
echo ""
