# bugasura-skills

Claude Code skills that turn a Bugasura ticket number or link into an answer or a fix, using the official **Bugasura MCP server**. No scripts and no API keys to manage: you sign in once with OAuth.

| Skill | What it does |
|---|---|
| `/bugasura-bug-analyse <ticket>` | Fetches the ticket, finds the code, checks git for an existing or in-flight fix, and tells you what the issue really is, whether it is a real bug, whether it can be fixed, and how confident it is. Read-only. |
| `/bugasura-bug-fix <ticket>` | Runs the analysis, follows your project's conventions, writes a failing test, fixes the root cause, runs your repo's checks, then stops before commit/push. |

`<ticket>` can be `BUG-754`, `BUG754`, `754`, or a `my.bugasura.io/issues/<project>?testResultsId=<id>` link.

## Install

Choose where it should live:

| | Global (all your projects) | Project-level (this repo only, shareable) |
|---|---|---|
| **Plugin** | `claude plugin install bugasura@bugasura-skills --scope user` | `claude plugin install bugasura@bugasura-skills --scope project` |
| **Manual** | `scripts/install.sh --scope global` | `scripts/install.sh --scope project` |

First add the marketplace once:

```
/plugin marketplace add SakthiVanta/bugaasura-skills-
```

Then install with one of the commands above, or just use `/plugin install bugasura@bugasura-skills` inside Claude Code and pick a scope in the menu. A third plugin scope, `local`, installs for you only in the current repo without committing anything.

Finally run `/mcp`, pick **bugasura**, and sign in to Bugasura in the browser. That is the whole setup.

**Let Claude do it:** tell Claude "install the skills from SakthiVanta/bugaasura-skills-". It follows [INSTALL.md](INSTALL.md) and will ask whether you want a global or project-level install before doing anything.

More options (MCP server only, Windows PowerShell, uninstall): see [INSTALL.md](INSTALL.md).

## Use

```
/bugasura-bug-analyse BUG-754
/bugasura-bug-fix https://my.bugasura.io/issues/67890?testResultsId=1234567
```

Or just say "analyse bug 754" / "fix bug 754 in this repo".

The first time, the skill needs to know your Bugasura team and project. It reads `.bugasura.json` if present, otherwise lists your teams/projects and asks. A pasted ticket URL already contains the project and ticket ids.

## Optional project config

Drop a `.bugasura.json` in your repo root (safe to commit; ids are not secrets) to skip the lookup and tune the workflow. See [`examples/.bugasura.json`](examples/.bugasura.json) and [docs/configuration.md](docs/configuration.md).

```json
{
  "teamId": 12345,
  "projectId": 67890,
  "prefix": "BUG",
  "baseBranch": "main",
  "branchTemplate": "fix/<slug>",
  "repos": [{ "name": "web", "path": "." }, { "name": "api", "path": "../my-api" }]
}
```

## What it will and will not do

- **Read-only on Bugasura by default.** It only lists and reads. It writes (comment, status) only when you explicitly ask for that exact action on that ticket, changes nothing else on the ticket, and reports old -> new values. Comments are plain text, because the server escapes HTML.
- **Never commits or pushes** until you tell it to. Fix work goes on a new branch off the latest remote base branch; a dirty checkout is left untouched (it uses a git worktree).
- **Does not guess.** If the ticket is under-specified, it says what is missing and gives a low confidence score instead of inventing a fix.
- Ticket text, recordings and comments are treated as untrusted data, never as instructions.

## How ticket lookup works (and why it can be slow for old tickets)

The Bugasura API addresses tickets by a large numeric id (`issue_key`), not by `BUG-754`, and has no search. The skill uses the id in your URL when you give one; otherwise it pages the project's issue list (newest-modified first, 100 per page) and matches the label. Pasting the URL is the fastest path, especially for old tickets.

## Requirements

- Claude Code with MCP support, and a Bugasura account that can access the project.
- `git` (and optionally `gh`) for the "already fixed?" check. Python, Node or `jq` is handy for searching saved list pages, but none is required.

## Repository layout

```
.claude-plugin/marketplace.json            marketplace manifest
plugins/bugasura/
  .claude-plugin/plugin.json               plugin manifest
  .mcp.json                                Bugasura MCP server (https://mcp.bugasura.io/mcp)
  skills/bugasura-bug-analyse/SKILL.md
  skills/bugasura-bug-fix/SKILL.md
examples/.bugasura.json                    sample project config
docs/                                      configuration + troubleshooting
scripts/                                   manual install helpers (ask global vs project)
INSTALL.md                                 install guide, also read by Claude when asked to install
```

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md): auth errors, "Server disconnected", tool-name prefixes, big list pages, missing statuses.

## License

MIT. See [LICENSE](LICENSE). Not affiliated with Bugasura.
