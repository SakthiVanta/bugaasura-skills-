# Manual install of the Bugasura skills + MCP server.
# Prefer the plugin route when you can:  /plugin marketplace add SakthiVanta/bugaasura-skills-
#
# Usage:
#   scripts\install.ps1                      # asks: global or project?
#   scripts\install.ps1 -Scope global        # ~\.claude\skills, MCP scope "user"   (all your projects)
#   scripts\install.ps1 -Scope project       # .\.claude\skills, MCP scope "project" (this repo, shareable)
param(
    [ValidateSet('global', 'project')]
    [string]$Scope
)
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $PSScriptRoot

if (-not $Scope) {
    if ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
        Write-Host 'Install the Bugasura skills:'
        Write-Host "  1) globally      - available in every project on this machine ($HOME\.claude\skills)"
        Write-Host "  2) project-level - only in the current repo ($((Get-Location).Path)\.claude\skills), can be committed for your team"
        $choice = Read-Host 'Choose 1 or 2'
        switch ($choice) {
            '1' { $Scope = 'global' }
            '2' { $Scope = 'project' }
            default { Write-Host 'cancelled'; exit 1 }
        }
    } else {
        Write-Error 'Pass -Scope global or -Scope project (no terminal to ask on).'
    }
}

if ($Scope -eq 'global') {
    $dest = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { Join-Path $HOME '.claude\skills' }
    $mcpScope = 'user'
} else {
    $dest = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { Join-Path (Get-Location).Path '.claude\skills' }
    $mcpScope = 'project'
}

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
        Write-Host 'bugasura MCP server already registered (left as is)'
    } else {
        claude mcp add --scope $mcpScope --transport http bugasura https://mcp.bugasura.io/mcp
    }
    Write-Host 'Next: run /mcp inside Claude Code and sign in to Bugasura.'
} else {
    Write-Host 'claude CLI not found. Register the server later with:'
    Write-Host "  claude mcp add --scope $mcpScope --transport http bugasura https://mcp.bugasura.io/mcp"
}
