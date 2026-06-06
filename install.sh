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

SCRIPT_VERSION="0.1.0"

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
    local line

    # Find the longest content line
    for line in "${lines[@]}"; do
        if [ ${#line} -gt $max_len ]; then
            max_len=${#line}
        fi
    done

    local content_width=$max_len
    local title_len=${#title}
    if [ $((title_len + 2)) -gt $content_width ]; then
        content_width=$((title_len + 2))
    fi
    local total_width=$((content_width + 4))

    # Top border with title
    local title_section=" $title "
    local side_dashes=$(((total_width - ${#title_section}) / 2))
    local top="╭"
    for ((i=0; i<side_dashes; i++)); do top="${top}─"; done
    top="${top}${title_section}"
    local right_dashes=$((total_width - ${#top} + 1))
    for ((i=0; i<right_dashes; i++)); do top="${top}─"; done
    top="${top}╮"
    printf "${CYAN}%s${NC}\n" "$top"

    # Content lines
    for line in "${lines[@]}"; do
        local padded="$line"
        local pad_len=$((content_width - ${#line}))
        for ((i=0; i<pad_len; i++)); do padded="${padded} "; done
        printf "${CYAN}│${NC} %s ${CYAN}│${NC}\n" "$padded"
    done

    # Bottom border
    local bottom="╰"
    for ((i=0; i<total_width; i++)); do bottom="${bottom}─"; done
    bottom="${bottom}╯"
    printf "${CYAN}%s${NC}\n" "$bottom"
}

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

    read -r CURRENT_VERSION_LINE < "$VERSION_FILE"
    # Format: 0.x.x | yyyy-MM-dd HH:mm sssssss mode
    VERSION="${CURRENT_VERSION_LINE%% | *}"
    REST="${CURRENT_VERSION_LINE#* | }"
    read -r INSTALLED_DATE INSTALLED_TIME INSTALLED_COMMIT INSTALLED_MODE <<< "$REST"

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

    # Try to fetch latest commit SHA from GitHub API (best-effort)
    LATEST_COMMIT=""
    UP_TO_DATE=false
    LATEST_COMMIT=$(curl -fsSL "https://api.github.com/repos/$REPO/commits/$BRANCH" 2>/dev/null \
        | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4 | cut -c1-7 || true)
    if [ -n "$LATEST_COMMIT" ]; then
        if [ "$LATEST_COMMIT" = "$INSTALLED_COMMIT" ]; then
            STATUS="✅ Up to date"
            UP_TO_DATE=true
        else
            STATUS="⬆️ Update available"
        fi
    else
        STATUS="⚠️ Could not check"
    fi

    # Build and display the update check box
    BOX_LINES=()
    BOX_LINES+=("Current:  $VERSION  ($INSTALLED_COMMIT)")
    if [ -n "$LATEST_COMMIT" ]; then
        BOX_LINES+=("Latest:   $SCRIPT_VERSION  ($LATEST_COMMIT)")
    fi
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
fi
echo "${SCRIPT_VERSION} | $NOW $SHA $MODE" > "$VERSION_FILE"

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

STATUS_LINE="✅ Vibuzo ${SCRIPT_VERSION} ${ACTION} successfully!"

# Build content lines (compact box)
BOX_LINES=()
if [ "$UPDATE" = true ]; then
    BOX_LINES+=("")
    BOX_LINES+=("Location:  $INSTALL_TARGET")
    BOX_LINES+=("")
else
    BOX_LINES+=("Location:  $INSTALL_TARGET")
    BOX_LINES+=("")
    BOX_LINES+=("── Next Steps ──")
    BOX_LINES+=("1. Restart opencode → select Vibuzo")
    BOX_LINES+=("2. Run /context init to scaffold project memory")
    BOX_LINES+=("3. Start building with /spec [feature description]")
    BOX_LINES+=("💡 github.com/AB-techsolutionists/vibuzo")
fi

# Calculate box width from content
MAX_LEN=${#STATUS_LINE}
MAX_LEN=$((MAX_LEN + 2))
for line in "${BOX_LINES[@]}"; do
    if [ ${#line} -gt $MAX_LEN ]; then
        MAX_LEN=${#line}
    fi
done
INNER_WIDTH=$((MAX_LEN + 4))

echo ""
# Top border with title
TITLE_SECTION=" $STATUS_LINE "
SIDE_DASHES=$(((INNER_WIDTH - ${#TITLE_SECTION}) / 2))
TOP="╭"
for ((i=0; i<SIDE_DASHES; i++)); do TOP="${TOP}─"; done
TOP="${TOP}${TITLE_SECTION}"
RIGHT_DASHES=$((INNER_WIDTH - ${#TOP} + 1))
for ((i=0; i<RIGHT_DASHES; i++)); do TOP="${TOP}─"; done
TOP="${TOP}╮"
printf "%s\n" "$TOP"
# Content lines
for line in "${BOX_LINES[@]}"; do
    if [ -z "$line" ]; then
        PAD=""
        for ((i=0; i<INNER_WIDTH; i++)); do PAD="${PAD} "; done
        printf "│${PAD}│\n"
    else
        PAD=""
        PAD_LEN=$((INNER_WIDTH - 2 - ${#line}))
        for ((i=0; i<PAD_LEN; i++)); do PAD="${PAD} "; done
        printf "│ ${line}${PAD} │\n"
    fi
done
# Bottom border
BOTTOM="╰"
for ((i=0; i<INNER_WIDTH; i++)); do BOTTOM="${BOTTOM}─"; done
BOTTOM="${BOTTOM}╯"
printf "%s\n" "$BOTTOM"
echo ""
