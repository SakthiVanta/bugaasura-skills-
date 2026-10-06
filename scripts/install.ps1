# Manual install: copy the skills into ~/.claude/skills and register the Bugasura MCP server.
# Prefer `/plugin marketplace add <owner>/bugasura-skills` when you can.
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $PSScriptRoot
$dest = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { Join-Path $HOME '.claude\skills' }

New-Item -ItemType Directory -Force -Path $dest | Out-Null
foreach ($skill in 'bugasura-bug-analyse', 'bugasura-bug-fix') {
    $target = Join-Path $dest $skill
    if (Test-Path $target) { Remove-Item -Recurse -Force $target }
    Copy-Item -Recurse (Join-Path $here "plugins\bugasura\skills\$skill") $target
    Write-Host "installed $skill -> $target"
}

if (Get-Command claude -ErrorAction SilentlyContinue) {
    $list = (claude mcp list 2>$null) -join "`n"
    if ($list -match '(?im)^bugasura:') {
        Write-Host 'bugasura MCP server already registered'
    } else {
        claude mcp add --transport http bugasura https://mcp.bugasura.io/mcp
    }
    Write-Host 'Next: run /mcp inside Claude Code and sign in to Bugasura.'
} else {
    Write-Host 'claude CLI not found. Register the server later with:'
    Write-Host '  claude mcp add --transport http bugasura https://mcp.bugasura.io/mcp'
}
