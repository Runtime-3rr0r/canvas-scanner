#!/bin/sh
# =============================================================================
# canvas-scanner suite setup
# macOS | Linux | Windows (Git Bash)
#
# What this does, in order:
#   1.  Installs Hermes Agent       (macOS/Linux only; on Windows use setup.bat)
#   2.  Adds your OpenRouter key    to $HERMES_HOME/.env
#   3.  Points Hermes at OpenRouter and the free Nemotron 550B model
#   4.  Installs the suite skills   into $HERMES_HOME/skills/
#   5.  Seeds templates and a starter school-config.md (fill it in after)
#   6.  Runs `hermes doctor`        to verify everything
#
# Safe to re-run. Nothing here touches other folders on your machine.
#
# Usage:
#   bash scripts/setup.sh                     # full setup (asks for API key)
#   OPENROUTER_API_KEY=sk-or-... bash scripts/setup.sh   # no prompt
#   bash scripts/setup.sh --no-install        # Hermes already installed
#   bash scripts/setup.sh --dry-run           # print, do not execute
#   bash scripts/setup.sh --no-doctor         # skip the final health check
#   bash scripts/setup.sh --with-gateway      # also install always-on gateway
# =============================================================================

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

INSTALL_HERMES=1
DRY=0
RUN_DOCTOR=1
WITH_GATEWAY=0

# ---- flag parsing -----------------------------------------------------------
for arg in "$@"; do
    case "$arg" in
        --no-install) INSTALL_HERMES=0 ;;
        --dry-run)    DRY=1 ;;
        --no-doctor)  RUN_DOCTOR=0 ;;
        --with-gateway) WITH_GATEWAY=1 ;;
        -h|--help)
            sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "setup.sh: unknown option: $arg"
            echo "run: bash scripts/setup.sh --help"
            exit 2
            ;;
    esac
done

# ---- tiny helpers -----------------------------------------------------------
say()  { printf '\n== %s\n' "$*"; }
note() { printf '  %s\n' "$*"; }

# prints the command, then runs it (unless --dry-run)
run() {
    printf '  $ %s\n' "$*"
    [ "$DRY" = 1 ] && return 0
    "$@"
}

# ---- 0. detect OS and resolve HERMES_HOME ----------------------------------
UNAME=$(uname -s 2>/dev/null || echo unknown)
case "$UNAME" in
    *MINGW*|*MSYS*|*CYGWIN*) OS=windows ;;
    Darwin) OS=macos ;;
    *)       OS=linux ;;
esac

if [ -n "${HERMES_HOME:-}" ]; then
    HERMES_HOME_HINT="$HERMES_HOME"
elif [ "$OS" = windows ]; then
    HERMES_HOME_HINT="${LOCALAPPDATA:-$HOME/AppData/Local}/hermes"
else
    HERMES_HOME_HINT="$HOME/.hermes"
fi

say "canvas-scanner setup"
note "OS detected: $OS"
note "Hermes data dir: $HERMES_HOME_HINT"

# ---- locate the hermes launcher ---------------------------------------------
find_hermes() {
    H=
    if command -v hermes >/dev/null 2>&1; then
        H=$(command -v hermes)
    elif [ "$OS" = windows ]; then
        for p in \
            "$LOCALAPPDATA/hermes/bin/hermes.exe" \
            "$HOME/AppData/Local/hermes/bin/hermes.exe" \
            "$HERMES_HOME_HINT/bin/hermes.exe"
        do
            [ -x "$p" ] && H="$p" && break
        done
    else
        for p in \
            "$HOME/.local/bin/hermes" \
            "$HOME/bin/hermes" \
            "/usr/local/bin/hermes" \
            "$HERMES_HOME_HINT/bin/hermes"
        do
            [ -x "$p" ] && H="$p" && break
        done
    fi
    printf '%s' "$H"
}
HERMES=$(find_hermes)

# ---- 1. install Hermes if needed ---------------------------------------------
if [ -z "$HERMES" ]; then
    if [ "$INSTALL_HERMES" = 0 ]; then
        echo
        echo "ERROR: Hermes Agent was not found on this machine."
        echo "Install it first, open a NEW terminal, then re-run:"
        echo "  bash scripts/setup.sh --no-install"
        case "$OS" in
            windows)
                echo
                echo "On Windows the easiest path is: double-click setup.bat"
                echo "  (it installs Hermes, then runs this script for you)"
                ;;
            macos|linux)
                echo
                echo "Install with:"
                echo "  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
                ;;
        esac
        exit 1
    fi

    case "$OS" in
        windows)
            echo
            echo "On Windows, Hermes installs through PowerShell, not bash."
            echo "Close this window and double-click setup.bat instead."
            echo "  (setup.bat installs Hermes, then runs this configuration automatically)"
            exit 1
            ;;
        *)
            if ! command -v curl >/dev/null 2>&1; then
                echo "ERROR: curl is required to download Hermes and was not found."
                echo "Open a browser, go to https://hermes-agent.nousresearch.com"
                echo "and follow the install instructions, then re-run:"
                echo "  bash scripts/setup.sh --no-install"
                exit 1
            fi
            say "Installing Hermes Agent (one-time download)"
            note "If an interactive setup wizard opens after the install,"
            note "press Ctrl+C to skip it. This script configures everything next."
            if [ "$DRY" = 1 ]; then
                printf '  $ curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash\n'
            else
                curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
            fi
            HERMES=$(find_hermes)
            if [ -z "$HERMES" ]; then
                echo
                echo "Hermes was installed, but this terminal has not picked up"
                echo "the new PATH yet. Open a NEW terminal window, go to your"
                echo "canvas-scanner folder, and run:"
                echo "  bash scripts/setup.sh --no-install"
                exit 0
            fi
            ;;
    esac
fi
note "hermes launcher: $HERMES"

# ---- 2. OpenRouter API key ----------------------------------------------------
ENV_FILE="$HERMES_HOME_HINT/.env"

have_key() {
    [ -f "$ENV_FILE" ] && grep -q '^OPENROUTER_API_KEY=.' "$ENV_FILE" 2>/dev/null
}

if have_key; then
    note "OpenRouter key already present in $ENV_FILE (leaving it untouched)"
else
    KEY=${OPENROUTER_API_KEY:-}
    if [ -z "$KEY" ] && [ -t 0 ]; then
        printf 'Paste your OpenRouter API key (from https://openrouter.ai/keys), then press Enter:\n> '
        stty -echo 2>/dev/null
        IFS= read -r KEY
        stty echo 2>/dev/null
        printf '\n'
    fi

    if [ -n "$KEY" ]; then
        # trim whitespace and stray line breaks
        KEY=$(printf '%s' "$KEY" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | tr -d '\r')
        if [ "$DRY" = 1 ]; then
            printf '  $ (append OPENROUTER_API_KEY to %s)\n' "$ENV_FILE"
        else
            mkdir -p "$(dirname "$ENV_FILE")"
            printf '\n# added by canvas-scanner setup\nOPENROUTER_API_KEY=%s\n' "$KEY" >> "$ENV_FILE"
        fi
        note "OpenRouter key written to $ENV_FILE"
    else
        echo
        echo "WARNING: no OpenRouter key was found and none was provided."
        echo "Continuing anyway; add it any time with:"
        echo "  echo 'OPENROUTER_API_KEY=sk-or-...' >> \"$ENV_FILE\""
        echo "or set it once with:  OPENROUTER_API_KEY=sk-or-... bash scripts/setup.sh"
    fi
fi

# ---- 3. provider + model (free Nemotron 550B via OpenRouter) -------------------
say "Configuring Hermes: OpenRouter + free Nemotron 550B"
run "$HERMES" config set model.provider openrouter
run "$HERMES" config set model.default "nvidia/nemotron-3-ultra-550b-a55b:free"
note "model notes: this model is free on OpenRouter (no billing needed)."

# ---- 4. copy the suite skills ---------------------------------------------------
SKILLS_SRC="$ROOT/skills"
SKILLS_DST="$HERMES_HOME_HINT/skills"
if [ -d "$SKILLS_SRC" ]; then
    say "Installing suite skills"
    run mkdir -p "$SKILLS_DST"
    run cp -R "$SKILLS_SRC/." "$SKILLS_DST/"
    note "skills copied to $SKILLS_DST (they appear in Hermes from your next session)"
fi

# templates (school-inbox soul + companions)
TPL_SRC="$ROOT/templates"
TPL_DST="$HERMES_HOME_HINT/templates"
if [ -d "$TPL_SRC" ]; then
    run mkdir -p "$TPL_DST"
    run cp -R -n "$TPL_SRC/." "$TPL_DST/"
    note "templates seeded to $TPL_DST"
fi

# ---- 5. starter school-config --------------------------------------------------
CFG="$HERMES_HOME_HINT/school-config.md"
if [ -f "$CFG" ]; then
    note "school-config.md already exists (leaving it untouched)"
else
    if [ -f "$ROOT/school-config.example.md" ]; then
        run mkdir -p "$HERMES_HOME_HINT"
        run cp "$ROOT/school-config.example.md" "$CFG"
        echo
        echo "CREATED: $CFG"
        echo "Open that file and replace the example values with YOUR school's real ones"
        echo "(student id, Canvas domain, course ids, instructors). The skills read it"
        echo "from there; you never edit a skill file with personal data. This file is"
        echo "yours alone and is never uploaded."
    fi
fi

# ---- 6. optional always-on gateway ----------------------------------------------
if [ "$WITH_GATEWAY" = 1 ]; then
    say "Installing the background gateway (starts automatically at login)"
    run "$HERMES" gateway install
    run "$HERMES" gateway start
else
    note "gateway: not installed as a service (the desktop app manages its own)."
    note "For an always-on background gateway, re-run with:  --with-gateway"
fi

# ---- 7. verify -------------------------------------------------------------------
if [ "$RUN_DOCTOR" = 1 ]; then
    say "Health check (hermes doctor)"
    if [ "$DRY" = 1 ]; then
        printf '  $ %s doctor\n' "$HERMES"
    else
        "$HERMES" doctor || true
    fi
fi

# ---- summary ----------------------------------------------------------------------
say "Setup complete"
note "Next steps"
note "  1. Open a NEW terminal and launch the desktop app:"
note "       hermes desktop"
note "  2. If you did not add an OpenRouter key yet, do that now (see the"
note "     WARNING above), then restart Hermes."
note "  3. In the desktop app, open your school's Canvas URL in the preview"
note "     pane and sign in once (this session is what the scanner reads)."
note "  4. Create a Classes folder and ask Hermes:"
note "       \"run the canvas course sync\""
note "  5. Anything confusing? Paste the output of  hermes doctor  into an"
note "     AI chat along with this repo's AI-SETUP-GUIDE.md for help."
exit 0