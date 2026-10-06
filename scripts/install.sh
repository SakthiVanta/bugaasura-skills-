#!/usr/bin/env bash
# Manual install of the Bugasura skills + MCP server.
# Prefer the plugin route when you can:  /plugin marketplace add SakthiVanta/bugaasura-skills-
#
# Usage:
#   scripts/install.sh                    # asks: global or project?
#   scripts/install.sh --scope global     # ~/.claude/skills, MCP scope "user"   (all your projects)
#   scripts/install.sh --scope project    # ./.claude/skills, MCP scope "project" (this repo, shareable)
#   CLAUDE_SKILLS_DIR=/custom/path scripts/install.sh --scope global
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scope=""
while [ $# -gt 0 ]; do
  case "$1" in
    --scope) scope="${2:-}"; shift 2 ;;
    --scope=*) scope="${1#--scope=}"; shift ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$scope" ]; then
  if [ -t 0 ]; then
    echo "Install the Bugasura skills:"
    echo "  1) globally      - available in every project on this machine (~/.claude/skills)"
    echo "  2) project-level - only in the current repo ($(pwd)/.claude/skills), can be committed for your team"
    read -r -p "Choose 1 or 2: " choice
    case "$choice" in 1) scope=global ;; 2) scope=project ;; *) echo "cancelled" >&2; exit 1 ;; esac
  else
    echo "Pass --scope global or --scope project (no terminal to ask on)." >&2
    exit 2
  fi
fi

case "$scope" in
  global)  dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"; mcp_scope=user ;;
  project) dest="${CLAUDE_SKILLS_DIR:-$(pwd)/.claude/skills}"; mcp_scope=project ;;
  *) echo "--scope must be 'global' or 'project'" >&2; exit 2 ;;
esac

mkdir -p "$dest"
for skill in bugasura-bug-analyse bugasura-bug-fix; do
  rm -rf "${dest:?}/$skill"
  cp -R "$here/plugins/bugasura/skills/$skill" "$dest/$skill"
  echo "installed $skill -> $dest/$skill"
done

if command -v claude >/dev/null 2>&1; then
  if claude mcp list 2>/dev/null | grep -qi '^bugasura:'; then
    echo "bugasura MCP server already registered (left as is)"
  else
    claude mcp add --scope "$mcp_scope" --transport http bugasura https://mcp.bugasura.io/mcp
  fi
  echo "Next: run /mcp inside Claude Code and sign in to Bugasura."
else
  echo "claude CLI not found. Register the server later with:"
  echo "  claude mcp add --scope $mcp_scope --transport http bugasura https://mcp.bugasura.io/mcp"
fi
