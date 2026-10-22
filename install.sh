#!/usr/bin/env sh
# Install the ui-ux-sketchbook skill for one or more coding agents.
#
#   curl -fsSL https://raw.githubusercontent.com/TssHack/ui-ux-sketchbook/main/install.sh | sh
#   curl -fsSL https://raw.githubusercontent.com/TssHack/ui-ux-sketchbook/main/install.sh | sh -s -- --agent hermes
#
# Options:
#   --agent NAME   claude | codex | cursor | hermes | all   (default: every agent found on this machine, else claude)
#   --project      install into the current project (./.claude/skills, ./.agents/skills, ...) instead of your home folder
#   --dir PATH     install into PATH/ui-ux-sketchbook (any other agent)
#   --version TAG  a release tag such as v1.0.0 (default: latest release)
set -eu

REPO="TssHack/ui-ux-sketchbook"
NAME="ui-ux-sketchbook"
AGENTS=""
PROJECT=0
CUSTOM_DIR=""
VERSION="latest"

while [ $# -gt 0 ]; do
  case "$1" in
    --agent) AGENTS="$AGENTS $2"; shift 2 ;;
    --project) PROJECT=1; shift ;;
    --dir) CUSTOM_DIR="$2"; shift 2 ;;
    --version) VERSION="$2"; shift 2 ;;
    -h|--help) sed -n '2,13p' "$0" 2>/dev/null || true; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

target_for() {
  if [ "$PROJECT" = 1 ]; then
    case "$1" in
      claude) echo "./.claude/skills" ;;
      codex) echo "./.agents/skills" ;;
      cursor) echo "./.cursor/skills" ;;
      hermes) echo "./.hermes/skills" ;;
    esac
  else
    case "$1" in
      claude) echo "$HOME/.claude/skills" ;;
      codex) echo "$HOME/.codex/skills" ;;
      cursor) echo "$HOME/.cursor/skills" ;;
      hermes) echo "$HOME/.hermes/skills" ;;
    esac
  fi
}

# Default: every agent that already has a config folder, or Claude Code if none do.
if [ -z "$AGENTS" ] && [ -z "$CUSTOM_DIR" ]; then
  for a in claude codex cursor hermes; do
    [ -d "$HOME/.$a" ] && AGENTS="$AGENTS $a"
  done
  [ -z "$AGENTS" ] && AGENTS="claude"
fi
case "$AGENTS" in *all*) AGENTS="claude codex cursor hermes" ;; esac

# Use a local checkout when the script runs from one, otherwise download the release.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || echo "")
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/skills/$NAME/SKILL.md" ]; then
  SRC="$SCRIPT_DIR/skills/$NAME"
else
  TMP=$(mktemp -d)
  trap 'rm -rf "$TMP"' EXIT
  if [ "$VERSION" = "latest" ]; then
    URL="https://github.com/$REPO/releases/latest/download/$NAME.tar.gz"
  else
    URL="https://github.com/$REPO/releases/download/$VERSION/$NAME.tar.gz"
  fi
  echo "Downloading $URL"
  if command -v curl >/dev/null 2>&1; then curl -fsSL "$URL" -o "$TMP/skill.tar.gz"
  else wget -qO "$TMP/skill.tar.gz" "$URL"; fi
  tar -xzf "$TMP/skill.tar.gz" -C "$TMP"
  SRC="$TMP/$NAME"
fi

[ -f "$SRC/SKILL.md" ] || { echo "SKILL.md not found in $SRC" >&2; exit 1; }

install_to() {
  dest="$1/$NAME"
  mkdir -p "$1"
  rm -rf "$dest"
  cp -R "$SRC" "$dest"
  echo "  installed -> $dest"
}

echo "Installing $NAME"
[ -n "$CUSTOM_DIR" ] && install_to "$CUSTOM_DIR"
for a in $AGENTS; do
  t=$(target_for "$a")
  [ -n "$t" ] || { echo "Unknown agent: $a (use claude, codex, cursor, hermes or --dir)" >&2; exit 1; }
  printf '%s:' "$a"; echo; install_to "$t"
done
echo "Done. Restart your agent so it picks up the new skill."
