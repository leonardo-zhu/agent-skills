---
name: git-identity
description: Use when performing any git operation (commit, push, rebase, merge, cherry-pick, amend) or any GitHub API interaction - ensures all operations use the bot identity instead of personal credentials
---

# Git & GitHub Bot Identity

All git operations and GitHub API calls must use the `leonardo-github-assist[bot]` identity. Never use personal credentials.

## Bot Identity

| Field | Value |
|-------|-------|
| Name | `leonardo-github-assist[bot]` |
| Email | `271226941+leonardo-github-assist[bot]@users.noreply.github.com` |

## Per-Agent Configuration

| Agent | gitconfig 路径 | Co-authored-by |
|-------|----------------|----------------|
| Claude Code | `~/.gitconfig.claude` | `Co-authored-by: Claude Code <271226941+leonardo-github-assist[bot]@users.noreply.github.com>` |
| Gemini CLI | `~/.gitconfig.gemini` | `Co-authored-by: Gemini <271226941+leonardo-github-assist[bot]@users.noreply.github.com>` |
| OpenClaw | `~/.gitconfig.openclaw` | `Co-authored-by: OpenClaw <271226941+leonardo-github-assist[bot]@users.noreply.github.com>` |
| Antigravity | `~/.gitconfig.antigravity` | `Co-authored-by: Antigravity <271226941+leonardo-github-assist[bot]@users.noreply.github.com>` |

## Git Commands

Every git command must specify both author and committer. Look up `{gitconfig}` from the Per-Agent Configuration table above.

```bash
GIT_COMMITTER_NAME="leonardo-github-assist[bot]" \
GIT_COMMITTER_EMAIL="271226941+leonardo-github-assist[bot]@users.noreply.github.com" \
git -c include.path={gitconfig} <command>
```

- `-c include.path` sets the **author** (reads `user.name` / `user.email` from your agent-specific gitconfig)
- `GIT_COMMITTER_*` sets the **committer** — required for rebase, merge, cherry-pick, and amend which set committer independently

Apply to **every** git command without exception.

## Commit Message Signature

Append your agent's Co-authored-by line (from the table above) to every commit message.

## GitHub API

Never use a personal PAT. Always:

1. Call `mcp__gh-mcp__get_installation_token` first
2. Use the returned Installation Access Token (IAT) as Bearer token for all REST and GraphQL requests

App ID and Installation ID are pre-configured in the MCP server environment — no manual input needed.

## Examples

Replace `{gitconfig}` and `{co-authored-by}` with your row from the Per-Agent Configuration table above.

```bash
# Commit
GIT_COMMITTER_NAME="leonardo-github-assist[bot]" \
GIT_COMMITTER_EMAIL="271226941+leonardo-github-assist[bot]@users.noreply.github.com" \
git -c include.path={gitconfig} commit \
  -m "feat: add feature" \
  -m "{co-authored-by}"

# Rebase
GIT_COMMITTER_NAME="leonardo-github-assist[bot]" \
GIT_COMMITTER_EMAIL="271226941+leonardo-github-assist[bot]@users.noreply.github.com" \
git -c include.path={gitconfig} rebase origin/main
```
