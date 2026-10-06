#!/usr/bin/env bash
# Manual install: copy the skills into ~/.claude/skills and register the Bugasura MCP server.
# Prefer `/plugin marketplace add <owner>/bugasura-skills` when you can.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

mkdir -p "$dest"
for skill in bugasura-bug-analyse bugasura-bug-fix; do
  rm -rf "${dest:?}/$skill"
  cp -R "$here/plugins/bugasura/skills/$skill" "$dest/$skill"
  echo "installed $skill -> $dest/$skill"
done

if command -v claude >/dev/null 2>&1; then
  if claude mcp list 2>/dev/null | grep -qi '^bugasura:'; then
    echo "bugasura MCP server already registered"
  else
    claude mcp add --transport http bugasura https://mcp.bugasura.io/mcp
  fi
  echo "Next: run /mcp inside Claude Code and sign in to Bugasura."
else
  echo "claude CLI not found. Register the server later with:"
  echo "  claude mcp add --transport http bugasura https://mcp.bugasura.io/mcp"
fi
