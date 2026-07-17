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
#   --no-color   Suppress ANSI color output
#   --yes, -y    Auto-confirm all prompts
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
    "deepsearcher.md"
    "deepviewer.md"
)

COMMAND_FILES=(
    "spec" "add-context" "context-init" "research" "session" "session-init" "deepviewer"
)

# ─── Arg Parsing ─────────────────────────────────────────────────────────────

GLOBAL=false
UPDATE=false
NO_COLOR="${NO_COLOR:-}"
YES=false

for arg in "$@"; do
    case "$arg" in
        --global) GLOBAL=true ;;
        --update) UPDATE=true ;;
        --no-color) NO_COLOR=true ;;
        --yes|-y) YES=true ;;
        --help)
            sed -n '2,16p' "$0"
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

# Color gating — clear ANSI codes if NO_COLOR is set (env var or --no-color flag)
if [ -n "$NO_COLOR" ]; then
    CYAN=''; GREEN=''; YELLOW=''; RED=''; NC=''
fi

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
    # Fixed box width matching the VIBUZO banner: 59 total, 55 content
    local total=59
    local max_len=$((total - 4))
    
    # Title section with spaces
    local title_section=" $title "
    local title_len=${#title_section}
    
    # Dashes: (total - 2 corners - title) split evenly
    local dash_space=$((total - 2 - title_len))
    local left_dashes=$((dash_space / 2))
    local right_dashes=$((dash_space - left_dashes))
    
    # Top border
    printf "${CYAN}╔"
    for ((i=0; i<left_dashes; i++)); do printf "═"; done
    printf "%s" "$title_section"
    for ((i=0; i<right_dashes; i++)); do printf "═"; done
    printf "╗${NC}\n"

    # Content lines
    for line in "${lines[@]}"; do
        # Check for divider line (3+ ═ characters, with optional surrounding whitespace)
        if [[ "$line" =~ ^[[:space:]]*═{3,}[[:space:]]*$ ]]; then
            local divider_content=""
            for ((i=0; i<max_len; i++)); do divider_content="${divider_content}═"; done
            printf "${CYAN}║${NC} %s ${CYAN}║${NC}\n" "$divider_content"
            continue
        fi
        # Account for emoji double-width (✅❌ render as 2 columns, count as 1 char)
        local stripped="${line//[✅❌]/}"
        local emoji_extra=$(( ${#line} - ${#stripped} ))
        local pad_len=$((max_len - ${#line} - emoji_extra))
        if [ $pad_len -lt 0 ]; then pad_len=0; fi
        printf "${CYAN}║${NC} %s" "$line"
        for ((i=0; i<pad_len; i++)); do printf " "; done
        printf " ${CYAN}║${NC}\n"
    done

    # Bottom border
    printf "${CYAN}╚"
    for ((i=0; i<total - 2; i++)); do printf "═"; done
    printf "╝${NC}\n"
}

# ─── Spinner & Step Renderer ────────────────────────────────────────────────

SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
SPINNER_IDX=0

write_spinner() {
    local message="$1"
    local step="$2"
    local completed="${3:-false}"
    local frame
    local prefix="Step $step/8"
    if [ "$completed" = true ]; then
        frame="✓"
        printf "\r  %s %s %s\n" "$prefix" "$frame" "$message"
    else
        frame="${SPINNER_FRAMES[$((SPINNER_IDX % ${#SPINNER_FRAMES[@]}))]}"
        SPINNER_IDX=$((SPINNER_IDX + 1))
        printf "\r  %s %s %s" "$prefix" "$frame" "$message"
    fi
}

write_step() {
    local title="$1"
    local step="$2"
    local total="$3"
    local completed="${4:-false}"
    local mark
    if [ "$completed" = true ]; then
        mark="✓"
        printf "${GREEN}  Step %s/%s: %s${NC}\n" "$step" "$total" "$title"
    else
        mark="→"
        printf "${CYAN}  Step %s/%s: %s${NC}\n" "$step" "$total" "$title"
    fi
}

# ─── Prompt Helper ──────────────────────────────────────────────────────────

confirm_action() {
    local prompt="$1"
    local default="${2:-n}"
    if [ "$YES" = true ]; then
        return 0
    fi
    if [ ! -t 0 ]; then
        if [ "$default" = "y" ]; then return 0; else return 1; fi
    fi
    local suffix
    if [ "$default" = "y" ]; then suffix="(Y/n)"; else suffix="(y/N)"; fi
    local response
    printf "%s %s: " "$prompt" "$suffix"
    read -r response
    case "$response" in
        y|Y|yes|YES) return 0 ;;
        n|N|no|NO) return 1 ;;
        *) if [ "$default" = "y" ]; then return 0; else return 1; fi ;;
    esac
}

# ─── Environment Detection ──────────────────────────────────────────────────

DETECTED_OS=""
DETECTED_ARCH=""
DETECTED_HAS_CURL=false
DETECTED_HAS_WGET=false
DETECTED_HAS_GIT=false
DETECTED_HAS_PWSH=false
DETECTED_TERM_WIDTH=80
DETECTED_IS_TTY=false

detect_environment() {
    write_step "Detecting Environment" 1 8

    write_spinner "Checking operating system..." 1
    case "$(uname -s)" in
        Linux*)  DETECTED_OS="Linux" ;;
        Darwin*) DETECTED_OS="macOS" ;;
        CYGWIN*|MINGW*|MSYS*) DETECTED_OS="Windows" ;;
        *)       DETECTED_OS="Unknown" ;;
    esac

    write_spinner "Checking architecture..." 1
    case "$(uname -m)" in
        x86_64|amd64) DETECTED_ARCH="x64" ;;
        aarch64|arm64) DETECTED_ARCH="ARM64" ;;
        *)             DETECTED_ARCH="$(uname -m)" ;;
    esac

    write_spinner "Checking available tools..." 1
    command -v curl &>/dev/null && DETECTED_HAS_CURL=true || DETECTED_HAS_CURL=false
    command -v wget &>/dev/null && DETECTED_HAS_WGET=true || DETECTED_HAS_WGET=false
    command -v git &>/dev/null && DETECTED_HAS_GIT=true || DETECTED_HAS_GIT=false
    command -v pwsh &>/dev/null && DETECTED_HAS_PWSH=true || DETECTED_HAS_PWSH=false

    write_spinner "Checking shell version..." 1
    DETECTED_BASH_VERSION=""
    if [ -n "$BASH_VERSION" ]; then
        DETECTED_BASH_VERSION="$BASH_VERSION"
    elif command -v bash &>/dev/null; then
        DETECTED_BASH_VERSION=$(bash --version 2>/dev/null | head -1)
    fi

    if command -v tput &>/dev/null; then
        DETECTED_TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
    fi
    if [ -t 0 ]; then
        DETECTED_IS_TTY=true
    fi

    write_spinner "Environment detection complete" 1 true

    if [ "${1:-}" = "--show-output" ]; then
        printf "  ${GREEN}✓ OS: $DETECTED_OS ($DETECTED_ARCH)${NC}\n"
        printf "  ${GREEN}✓ Shell: Bash $DETECTED_BASH_VERSION${NC}\n"
        printf "  ${GREEN}✓ Tools:${NC}\n"
        for tool in curl wget git pwsh; do
            local var="DETECTED_HAS_$(echo "$tool" | tr '[:lower:]' '[:upper:]')"
            if [ "${!var}" = true ]; then
                printf "    ✓ $tool\n"
            else
                printf "    ✗ $tool\n"
            fi
        done
        local tty_str="Piped"
        if [ "$DETECTED_IS_TTY" = true ]; then tty_str="TTY"; fi
        printf "  ${GREEN}✓ Terminal: $DETECTED_TERM_WIDTH cols, $tty_str${NC}\n"
    fi
}

# ─── Install State Detection ────────────────────────────────────────────────

INSTALL_STATE="absent"
INSTALLED_VERSION=""
INSTALLED_DATE=""
INSTALLED_MODE=""

detect_install_state() {
    write_step "Checking Installation" 2 8
    write_spinner "Checking for existing installation..." 2

    INSTALL_STATE="absent"
    INSTALLED_VERSION=""
    INSTALLED_DATE=""
    INSTALLED_MODE=""

    if [ -f ".opencode/.vibuzo-version" ]; then
        read -r content < ".opencode/.vibuzo-version"
        local IFS='|'
        local parts=($content)
        unset IFS
        INSTALLED_VERSION="$(echo "${parts[0]}" | xargs)"
        local rest="$(echo "${parts[1]}" | xargs)"
        local rest_parts=($rest)
        INSTALLED_DATE="${rest_parts[0]} ${rest_parts[1]}"
        INSTALLED_MODE="${rest_parts[2]}"

        local agent_count=0 cmd_count=0
        if [ -d ".opencode/agent/core" ]; then
            agent_count=$(ls .opencode/agent/core/*.md 2>/dev/null | wc -l)
        fi
        if [ -d ".opencode/commands" ]; then
            cmd_count=$(ls .opencode/commands/*.md 2>/dev/null | wc -l)
        fi

        if [ "$agent_count" -eq 4 ] && [ "$cmd_count" -eq 7 ]; then
            if [ "$INSTALLED_VERSION" = "$SCRIPT_VERSION" ]; then
                INSTALL_STATE="uptodate"
            else
                INSTALL_STATE="outdated"
            fi
        else
            INSTALL_STATE="partial"
        fi
    fi

    write_spinner "Install state check complete" 2 true
}

# ─── AI Tool Detection ─────────────────────────────────────────────────────

# Globals populated by detect_ai_tools
DETECTED_CLAUDE=false
DETECTED_OPENCODE=false
DETECTED_CLINE=false
DETECTED_CURSOR=false
DETECTED_COPILOT=false
DETECTED_GEMINI=false
DETECTED_WINDSURF=false
DETECTED_CODEX=false

detect_ai_tools() {
    write_step "Detecting AI Tools" 3 8
    write_spinner "Scanning for AI coding agents..." 3

    DETECTED_CLAUDE=false; DETECTED_OPENCODE=false; DETECTED_CLINE=false
    DETECTED_CURSOR=false; DETECTED_COPILOT=false; DETECTED_GEMINI=false; DETECTED_WINDSURF=false; DETECTED_CODEX=false

    command -v claude &>/dev/null && DETECTED_CLAUDE=true
    [ -d ".claude" ] && DETECTED_CLAUDE=true

    command -v opencode &>/dev/null && DETECTED_OPENCODE=true
    [ -d ".opencode" ] && DETECTED_OPENCODE=true

    [ -d ".cline" ] && DETECTED_CLINE=true
    [ -d ".github/agents" ] && DETECTED_CLINE=true

    command -v cursor &>/dev/null && DETECTED_CURSOR=true
    [ -d ".cursor" ] && DETECTED_CURSOR=true

    if command -v gh &>/dev/null && gh copilot --help &>/dev/null; then
        DETECTED_COPILOT=true
    fi

    command -v gemini &>/dev/null && DETECTED_GEMINI=true

    [ -d ".windsurf" ] && DETECTED_WINDSURF=true

    command -v codex &>/dev/null && DETECTED_CODEX=true

    write_spinner "Tool detection complete" 3 true

    local count=0
    for tool in "$DETECTED_CLAUDE" "$DETECTED_OPENCODE" "$DETECTED_CLINE" "$DETECTED_CURSOR" "$DETECTED_COPILOT" "$DETECTED_GEMINI" "$DETECTED_WINDSURF" "$DETECTED_CODEX"; do
        [ "$tool" = true ] && count=$((count + 1))
    done
    printf "  ${GREEN}✓ Detected: $count tool(s)${NC}\n"
    local icon
    icon="✓"; [ "$DETECTED_CLAUDE" = false ] && icon="✗"; printf "    $icon Claude Code\n"
    icon="✓"; [ "$DETECTED_OPENCODE" = false ] && icon="✗"; printf "    $icon opencode\n"
    icon="✓"; [ "$DETECTED_CLINE" = false ] && icon="✗"; printf "    $icon Cline\n"
    icon="✓"; [ "$DETECTED_CURSOR" = false ] && icon="✗"; printf "    $icon Cursor\n"
    icon="✓"; [ "$DETECTED_COPILOT" = false ] && icon="✗"; printf "    $icon Copilot CLI\n"
    icon="✓"; [ "$DETECTED_GEMINI" = false ] && icon="✗"; printf "    $icon Gemini CLI\n"
    icon="✓"; [ "$DETECTED_WINDSURF" = false ] && icon="✗"; printf "    $icon Windsurf\n"
    icon="✓"; [ "$DETECTED_CODEX" = false ] && icon="✗"; printf "    $icon Codex CLI\n"
}

# ─── Integration Installer ─────────────────────────────────────────────────

INTEGRATION_LIST="none"

install_integrations() {
    write_step "Configuring Integrations" 7 8
    local tools=""
    local count=0

    if [ "$DETECTED_CLAUDE" = true ]; then
        local dir=".claude/agents"
        mkdir -p "$dir"
        for f in "${AGENT_FILES[@]}"; do
            cp "$AGENTS_DIR/$f" "$dir/$f"
        done
        count=$((count + 1))
        tools="$tools Claude Code"
    fi

    if [ "$DETECTED_CLINE" = true ]; then
        local dir=".cline/agents"
        [ -d ".cline" ] || dir=".github/agents"
        mkdir -p "$dir"
        for f in "${AGENT_FILES[@]}"; do
            cp "$AGENTS_DIR/$f" "$dir/$f"
        done
        count=$((count + 1))
        tools="$tools Cline"
    fi

    if [ "$DETECTED_CODEX" = true ]; then
        local dir=".codex/agents"
        mkdir -p "$dir"
        for f in "${AGENT_FILES[@]}"; do
            cp "$AGENTS_DIR/$f" "$dir/$f"
        done
        count=$((count + 1))
        tools="$tools Codex CLI"
    fi

    if [ "$DETECTED_CURSOR" = true ]; then
        local dir=".cursor/agents"
        mkdir -p "$dir"
        for f in "${AGENT_FILES[@]}"; do
            cp "$AGENTS_DIR/$f" "$dir/$f"
        done
        count=$((count + 1))
        tools="$tools Cursor"
    fi

    if [ "$count" -eq 0 ]; then
        echo "  (no integrations to configure)"
        INTEGRATION_LIST="none"
    else
        INTEGRATION_LIST="$(echo "$tools" | xargs | tr ' ' ',')"
    fi
}

# ─── Project Files Helpers ─────────────────────────────────────────────────

save_project_files() {
    # Check AGENTS.md status
    local existing_content=""
    local user_rules=""
    local agents_status="fresh copy"

    if [ -f "AGENTS.md" ]; then
        if grep -q "PASTE YOUR CUSTOM RULES BELOW THIS LINE" AGENTS.md 2>/dev/null; then
            user_rules=$(awk '/PASTE YOUR CUSTOM RULES BELOW THIS LINE/{found=1; next} found' AGENTS.md 2>/dev/null)
            if [ -n "$user_rules" ]; then
                agents_status="with custom rules preserved"
            fi
        else
            existing_content=$(cat AGENTS.md)
            agents_status="your content preserved at top"
        fi
    fi

    printf "  ${GREEN}✓ AGENTS.md ($agents_status)${NC}\n"

    if ! confirm_action "Proceed with AGENTS.md?"; then
        printf "${YELLOW}AGENTS.md skipped.${NC}\n"
        return
    fi

    curl -fsSL "$RAW_URL/AGENTS.md" -o AGENTS.md
    if [ -n "$existing_content" ]; then
        local vibuzo_content
        vibuzo_content=$(cat AGENTS.md)
        printf "%s\n\n---\n\n%s" "$existing_content" "$vibuzo_content" > AGENTS.md
    elif [ -n "$user_rules" ]; then
        local fresh_after_marker
        fresh_after_marker=$(awk '/PASTE YOUR CUSTOM RULES BELOW THIS LINE/{found=1; next} found' AGENTS.md 2>/dev/null)
        if [ -z "$(echo "$fresh_after_marker" | tr -d '[:space:]')" ]; then
            printf "\n%s" "$user_rules" >> AGENTS.md
        fi
    fi
}

write_path_rewrite() {
    printf "   ${GREEN}✓ Path rewriting${NC}\n"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|\.opencode/context/|$OPENCODE_DIR/context/|g" "$AGENTS_DIR/vibuzo.md" "$AGENTS_DIR/deepveloper.md"
        sed -i '' "s|\.opencode/|$OPENCODE_DIR/|g" "$OPENCODE_DIR/AGENTS.md"
    else
        sed -i "s|\.opencode/context/|$OPENCODE_DIR/context/|g" "$AGENTS_DIR/vibuzo.md" "$AGENTS_DIR/deepveloper.md"
        sed -i "s|\.opencode/|$OPENCODE_DIR/|g" "$OPENCODE_DIR/AGENTS.md"
    fi
}

write_version_file() {
    local now
    now=$(date '+%Y-%m-%d %H:%M')
    local mode
    if [ "$GLOBAL" = true ]; then
        mode="global"
    else
        mode="local"
    fi
    echo "${SCRIPT_VERSION} | $now $mode" > "$VERSION_FILE"
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
║           Agentic Framework for AI Coding                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
printf "${NC}"

# ─── Prepare Directories ───────────────────────────────────────────────────

mkdir -p "$AGENTS_DIR" "$COMMANDS_DIR"

# ─── Wizard Flow ───────────────────────────────────────────────────────────

if [ "$UPDATE" = true ]; then
    # ─── Update Flow (Task 11) ──────────────────────────────────────────

    if [ ! -f "$VERSION_FILE" ]; then
        echo "❌ No existing Vibuzo installation found at $OPENCODE_DIR"
        echo "   Run without --update to install fresh."
        exit 1
    fi

    # Step 1/4: Check Version
    write_step "Checking Version" 1 4

    read -r CURRENT_VERSION_LINE < "$VERSION_FILE"
    VERSION="${CURRENT_VERSION_LINE%% | *}"
    REST="${CURRENT_VERSION_LINE#* | }"
    read -r INSTALLED_DATE INSTALLED_TIME INSTALLED_MODE <<< "$REST"

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

    UP_TO_DATE=false
    if [ "$VERSION" = "$SCRIPT_VERSION" ]; then
        STATUS="Up to date"
        UP_TO_DATE=true
    elif [ "$SCRIPT_VERSION" != "unknown" ]; then
        STATUS="Update available!"
    else
        STATUS="Could not check"
    fi

    local file_list="${#AGENT_FILES[@]} agents, ${#COMMAND_FILES[@]} commands, AGENTS.md"
    BOX_LINES=()
    BOX_LINES+=("Current:  $VERSION")
    BOX_LINES+=("Latest:   $SCRIPT_VERSION")
    BOX_LINES+=("Status:   $STATUS")
    BOX_LINES+=("")
    BOX_LINES+=("Last Update: $INSTALLED_FULL")
    BOX_LINES+=("Location:  $OPENCODE_DIR")
    BOX_LINES+=("")
    BOX_LINES+=("To be updated:")
    BOX_LINES+=("  $file_list")

    print_box "Vibuzo Update Check" "${BOX_LINES[@]}"

    if [ "$UP_TO_DATE" = true ]; then
        exit 0
    fi

    if ! confirm_action "Proceed with update?"; then
        printf "${YELLOW}Update cancelled.${NC}\n"
        exit 0
    fi

    # Step 2/4: Download Agents
    write_step "Downloading Agents" 2 4
    total=${#AGENT_FILES[@]}
    i=0
    for f in "${AGENT_FILES[@]}"; do
        i=$((i + 1))
        printf "  [$i/$total] $f... "
        if curl -fsSL "$RAW_URL/agents/$f" -o "$AGENTS_DIR/$f.tmp" 2>/dev/null; then
            mv "$AGENTS_DIR/$f.tmp" "$AGENTS_DIR/$f"
            printf "${GREEN}✓${NC}\n"
        else
            printf "${RED}✗${NC}\n"
            rm -f "$AGENTS_DIR/$f.tmp"
            write_spinner "Retrying $f..." 2
            sleep 1
            if curl -fsSL "$RAW_URL/agents/$f" -o "$AGENTS_DIR/$f.tmp" 2>/dev/null; then
                mv "$AGENTS_DIR/$f.tmp" "$AGENTS_DIR/$f"
                printf "  ${GREEN}[$i/$total] $f... ✓${NC}\n"
            else
                printf "  ${RED}[$i/$total] $f... ✗ FAILED${NC}\n"
            fi
        fi
    done

    # AGENTS.md handling + version file
    if [ "$GLOBAL" = false ]; then
        save_project_files
    else
        printf "  ${GREEN}✓ AGENTS.md (fresh copy)${NC}\n"
        curl -fsSL "$RAW_URL/AGENTS.md" -o "$OPENCODE_DIR/AGENTS.md"
    fi
    if [ "$GLOBAL" = true ]; then
        write_path_rewrite
    fi
    write_version_file

    # Step 3/4: Download Commands
    write_step "Downloading Commands" 3 4
    total=${#COMMAND_FILES[@]}
    i=0
    for f in "${COMMAND_FILES[@]}"; do
        i=$((i + 1))
        printf "  [$i/$total] $f.md... "
        if curl -fsSL "$RAW_URL/commands/$f.md" -o "$COMMANDS_DIR/$f.md.tmp" 2>/dev/null; then
            mv "$COMMANDS_DIR/$f.md.tmp" "$COMMANDS_DIR/$f.md"
            printf "${GREEN}✓${NC}\n"
        else
            printf "${RED}✗${NC}\n"
            rm -f "$COMMANDS_DIR/$f.md.tmp"
            write_spinner "Retrying $f.md..." 3
            sleep 1
            if curl -fsSL "$RAW_URL/commands/$f.md" -o "$COMMANDS_DIR/$f.md.tmp" 2>/dev/null; then
                mv "$COMMANDS_DIR/$f.md.tmp" "$COMMANDS_DIR/$f.md"
                printf "  ${GREEN}[$i/$total] $f.md... ✓${NC}\n"
            else
                printf "  ${RED}[$i/$total] $f.md... ✗ FAILED${NC}\n"
            fi
        fi
    done

    # Step 4/4: Configure Integrations
    write_step "Configuring Integrations" 4 4
    detect_ai_tools
    install_integrations

    # Post-update summary
    echo ""
    print_box "✅ Vibuzo ${SCRIPT_VERSION} updated successfully!" \
        "Location:  $INSTALL_TARGET" \
        "Version:   $SCRIPT_VERSION" \
        "Agents:    ${#AGENT_FILES[@]} installed ✓" \
        "Commands:  ${#COMMAND_FILES[@]} installed ✓" \
        "Integrations: $INTEGRATION_LIST" \
        "" \
        "═══════════════════════════════════════════════════════" \
        "" \
        "→ Restart opencode and select Vibuzo" \
        "  from the agent dropdown." \
        "" \
        "→ First time? Run /context init" \
        "  to set up project memory." \
        "" \
        "→ Start building with:" \
        "  /spec [feature description]" \
        "" \
        "💡 Learn more:" \
        "   github.com/AB-techsolutionists/vibuzo"
    echo ""
    exit 0
fi

# ─── Install Wizard Flow ────────────────────────────────────────────────────

# Step 1: Detect Environment
detect_environment

# Step 2: Detect Install State
detect_install_state
if [ "$INSTALL_STATE" = "uptodate" ]; then
    printf "  ${GREEN}✓ Vibuzo is already up to date ($INSTALLED_VERSION)${NC}\n"
    echo "  Run with --update to force reinstall."
    exit 0
fi

# Step 3: Detect AI Tools
detect_ai_tools

# Configure integrations prompt
if ! confirm_action "Configure AI tool integrations?" "y"; then
    DETECTED_CLAUDE=false; DETECTED_OPENCODE=false; DETECTED_CLINE=false
    DETECTED_CURSOR=false; DETECTED_COPILOT=false; DETECTED_GEMINI=false; DETECTED_WINDSURF=false; DETECTED_CODEX=false
fi

# Step 4: Installation Preview
write_step "Installation Preview" 4 8
printf "  ${CYAN}Target: $INSTALL_TARGET${NC}\n"
printf "  ${CYAN}Version: $SCRIPT_VERSION${NC}\n"
detected_count=0
    for tool in "$DETECTED_CLAUDE" "$DETECTED_OPENCODE" "$DETECTED_CLINE" "$DETECTED_CURSOR" "$DETECTED_COPILOT" "$DETECTED_GEMINI" "$DETECTED_WINDSURF" "$DETECTED_CODEX"; do
        [ "$tool" = true ] && detected_count=$((detected_count + 1))
    done
printf "  ${CYAN}AI Tools detected: $detected_count${NC}\n"

if ! confirm_action "Proceed with installation?" "y"; then
    echo "Installation cancelled."
    exit 0
fi

# Step 5: Download Agents
write_step "Downloading Agents" 5 8
total=${#AGENT_FILES[@]}
i=0
for f in "${AGENT_FILES[@]}"; do
    i=$((i + 1))
    printf "  [$i/$total] $f... "
    if curl -fsSL "$RAW_URL/agents/$f" -o "$AGENTS_DIR/$f.tmp" 2>/dev/null; then
        mv "$AGENTS_DIR/$f.tmp" "$AGENTS_DIR/$f"
        printf "${GREEN}✓${NC}\n"
    else
        printf "${RED}✗${NC}\n"
        rm -f "$AGENTS_DIR/$f.tmp"
        write_spinner "Retrying $f..." 5
        sleep 1
        if curl -fsSL "$RAW_URL/agents/$f" -o "$AGENTS_DIR/$f.tmp" 2>/dev/null; then
            mv "$AGENTS_DIR/$f.tmp" "$AGENTS_DIR/$f"
            printf "  ${GREEN}[$i/$total] $f... ✓${NC}\n"
        else
            printf "  ${RED}[$i/$total] $f... ✗ FAILED${NC}\n"
        fi
    fi
done

# AGENTS.md handling + version file
if [ "$GLOBAL" = false ]; then
    save_project_files
else
    printf "  ${GREEN}✓ AGENTS.md (fresh copy)${NC}\n"
    curl -fsSL "$RAW_URL/AGENTS.md" -o "$OPENCODE_DIR/AGENTS.md"
fi
if [ "$GLOBAL" = true ]; then
    write_path_rewrite
fi
write_version_file

# Step 6: Download Commands
write_step "Downloading Commands" 6 8
total=${#COMMAND_FILES[@]}
i=0
for f in "${COMMAND_FILES[@]}"; do
    i=$((i + 1))
    printf "  [$i/$total] $f.md... "
    if curl -fsSL "$RAW_URL/commands/$f.md" -o "$COMMANDS_DIR/$f.md.tmp" 2>/dev/null; then
        mv "$COMMANDS_DIR/$f.md.tmp" "$COMMANDS_DIR/$f.md"
        printf "${GREEN}✓${NC}\n"
    else
        printf "${RED}✗${NC}\n"
        rm -f "$COMMANDS_DIR/$f.md.tmp"
        write_spinner "Retrying $f.md..." 6
        sleep 1
        if curl -fsSL "$RAW_URL/commands/$f.md" -o "$COMMANDS_DIR/$f.md.tmp" 2>/dev/null; then
            mv "$COMMANDS_DIR/$f.md.tmp" "$COMMANDS_DIR/$f.md"
            printf "  ${GREEN}[$i/$total] $f.md... ✓${NC}\n"
        else
            printf "  ${RED}[$i/$total] $f.md... ✗ FAILED${NC}\n"
        fi
    fi
done

# Step 7: Configure Integrations
install_integrations

# Step 8: Post-Install Summary
echo ""
print_box "✅ Vibuzo ${SCRIPT_VERSION} installed successfully!" \
    "Location:  $INSTALL_TARGET" \
    "Version:   $SCRIPT_VERSION" \
    "Agents:    ${#AGENT_FILES[@]} installed ✓" \
    "Commands:  ${#COMMAND_FILES[@]} installed ✓" \
    "Integrations: $INTEGRATION_LIST" \
    "" \
    "═══════════════════════════════════════════════════════" \
    "" \
    "→ Restart opencode and select Vibuzo" \
    "  from the agent dropdown." \
    "" \
    "→ First time? Run /context init" \
    "  to set up project memory." \
    "" \
    "→ Start building with:" \
    "  /spec [feature description]" \
    "" \
    "💡 Learn more:" \
    "   github.com/AB-techsolutionists/vibuzo"
echo ""
