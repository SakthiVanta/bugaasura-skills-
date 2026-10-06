# Install instructions (for humans and for Claude)

> **Claude: if the user asked you to install this, do NOT pick a scope yourself. Ask first:**
>
> "Do you want the Bugasura skills installed **globally** (available in every project on this machine) or **project-level** (only in this repo, can be committed so your team gets them)?"
>
> Then follow the matching section below. Never overwrite existing skills of the same name without telling the user.

## Option A - Plugin (recommended)

```
/plugin marketplace add SakthiVanta/bugaasura-skills-
```

| Scope | Command | Where it lives | Who gets it |
|---|---|---|---|
| **Global** | `claude plugin install bugasura@bugasura-skills --scope user` | your user settings | you, in every project |
| **Project** | `claude plugin install bugasura@bugasura-skills --scope project` | the repo's `.claude/settings.json` | everyone who opens this repo and trusts it |
| **Local** | `claude plugin install bugasura@bugasura-skills --scope local` | your local-only project settings | only you, only in this repo (not committed) |

Inside Claude Code the interactive `/plugin` menu asks the same question when you install.

The plugin registers the Bugasura MCP server (`https://mcp.bugasura.io/mcp`) for you. Finish by running `/mcp` and signing in to Bugasura.

## Option B - Manual copy

```
scripts/install.sh                  # asks: global or project?
scripts/install.sh --scope global   # ~/.claude/skills        + MCP scope "user"
scripts/install.sh --scope project  # ./.claude/skills        + MCP scope "project"
```

Windows PowerShell: `scripts\install.ps1` (same, with `-Scope global|project`).

Run the project variant from the **root of the repo** you want the skills in. It writes `.claude/skills/` (commit it to share) and, if the server is not registered yet, a project-scoped entry in `.mcp.json` (teammates are asked to approve it the first time).

## Option C - MCP server only

```
claude mcp add --scope user    --transport http bugasura https://mcp.bugasura.io/mcp   # global
claude mcp add --scope project --transport http bugasura https://mcp.bugasura.io/mcp   # this repo, shareable
claude mcp add --scope local   --transport http bugasura https://mcp.bugasura.io/mcp   # just you, this repo
```

## After installing

1. `/mcp` -> **bugasura** -> sign in (browser OAuth; Claude cannot do this for you).
2. Try `/bugasura-bug-analyse <ticket number or URL>`.
3. Optional: add a `.bugasura.json` to your repo (see `examples/.bugasura.json`).

## Uninstall

- Plugin: `claude plugin uninstall bugasura@bugasura-skills --scope <same scope you installed with>`.
- Manual: delete `bugasura-bug-analyse` and `bugasura-bug-fix` from the skills folder you used; `claude mcp remove bugasura --scope <scope>`.
