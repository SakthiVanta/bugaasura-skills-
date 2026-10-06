# Troubleshooting

**"Sign in to Bugasura again" / no Bugasura tools**
The MCP server is not connected or the session expired. Run `/mcp`, select **bugasura**, and sign in. Check the server is registered: `claude mcp list` should show `bugasura: https://mcp.bugasura.io/mcp`. If not: `claude mcp add --transport http bugasura https://mcp.bugasura.io/mcp`. Non-interactive runs (CI, `claude -p`) cannot complete the OAuth flow.

**"Server disconnected without sending a response"**
Transient. Reads can simply be retried. For a write (comment/status), first re-read the ticket or its comments to confirm it did not apply, then retry once, so you never post twice.

**The tool names look different**
With the plugin installed they are prefixed `mcp__plugin_bugasura_bugasura__`; with `claude mcp add` they are `mcp__bugasura__`. The skills match on the `bugasura_<action>` suffix and load tools through ToolSearch.

**Ticket lookup returns huge files**
`bugasura_list_issues` pages are about 100 KB and are saved to disk. That is expected. Paste the ticket URL (it contains the numeric id) to skip paging entirely.

**"Ticket not found"**
The label must match the project's prefix (`BUG754`, not `BUG-754` internally - the skill normalises both). Check you are in the right team/project, and that the ticket was not moved or deleted. Pass the URL if unsure.

**Status name not accepted**
Statuses are per project and the API has no list call. Open a few tickets (or ask the skill to list distinct `status` values from the issue list) to see the exact names, including spaces and hyphens, e.g. `Ready to Test`.

**HTML tags show up in a comment**
The server escapes HTML. The skills post plain text; if you edit the text yourself, avoid tags.

**Windows: Unicode errors while searching saved pages**
Open the saved JSON with `encoding='utf-8'`.
