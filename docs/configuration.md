# Configuration

Everything is optional. Without a config the skills ask once and carry on.

## `.bugasura.json` (repo root)

| Key | Type | Meaning | Default |
|---|---|---|---|
| `teamId` | number | Bugasura team id | looked up with `bugasura_list_teams` |
| `projectId` | number | Bugasura project id | looked up with `bugasura_list_projects` |
| `prefix` | string | Ticket prefix, e.g. `BUG` | read from the ticket label |
| `baseBranch` | string | Branch fixes start from and PRs target | `origin/HEAD`'s branch |
| `branchTemplate` | string | Branch name for fixes; `<slug>` is replaced by a short description | `fix/<slug>` |
| `repos` | array of `{name, path}` | Other repos to search for callers and code (paths relative to this repo) | current repo only |

Find your ids: open any issue in Bugasura. The URL looks like `https://my.bugasura.io/issues/<projectId>?testResultsId=<issueKey>`. The team id comes from `bugasura_list_projects` (or ask Claude: "list my Bugasura projects").

The file contains no secrets and can be committed so the whole team shares it.

## Project conventions

The fix skill follows whatever your repo already documents: `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, design/architecture notes, and any architecture skill you have installed. Put your rules there (test runner, lint policy, "never use npm", branch naming). The skills discover the checks from `package.json`, `Makefile`, `pyproject.toml` and CI config.

## Permissions

The skills only need the Bugasura MCP tools plus normal git/shell access. To avoid permission prompts for read-only lookups, allow these in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__bugasura__bugasura_get_issue",
      "mcp__bugasura__bugasura_list_issues",
      "mcp__bugasura__bugasura_list_issue_comments",
      "mcp__bugasura__bugasura_list_teams",
      "mcp__bugasura__bugasura_list_projects",
      "mcp__bugasura__bugasura_find_project_by_name"
    ]
  }
}
```

When installed as a plugin the tool prefix differs (`mcp__plugin_bugasura_bugasura__...`); copy the exact names from a permission prompt. Do **not** pre-allow the write tools (`add_issue_comment`, `update_issue`, ...) - the prompt is a useful safety net.
