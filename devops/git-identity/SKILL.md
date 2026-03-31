---
name: git-identity
description: Use when performing any git operation (commit, push, fetch, pull, rebase, merge, cherry-pick, amend) or any GitHub API interaction - ensures all operations use the bot identity instead of personal credentials
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
| Gemini CLI | `~/.gitconfig.gemini` | `Co-authored-by: Gemini CLI <271226941+leonardo-github-assist[bot]@users.noreply.github.com>` |
| OpenClaw | `~/.gitconfig.openclaw` | `Co-authored-by: OpenClaw <271226941+leonardo-github-assist[bot]@users.noreply.github.com>` |
| Antigravity | `~/.gitconfig.antigravity` | `Co-authored-by: Antigravity <271226941+leonardo-github-assist[bot]@users.noreply.github.com>` |
| Codex CLI | `~/.gitconfig.codex` | `Co-authored-by: Codex CLI <271226941+leonardo-github-assist[bot]@users.noreply.github.com>` |

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

## GitHub API & Remote Operations (Git Push)

Never use a personal PAT for API calls or remote Git operations (push/pull/fetch).

### Authentication Flow

1. **Get Token**: Call `mcp__gh-mcp__get_installation_token` to get an Installation Access Token (IAT).
2. **API Calls**: Set `Authorization: Bearer <IAT>` for all REST/GraphQL requests.
3. **Git Push/Fetch**: Treat these as GitHub platform operations. Use the IAT in the URL to ensure the bot identity is used and your personal PAT is not leaked.

   ```bash
   git push https://x-access-token:<IAT>@github.com/<owner>/<repo>.git <branch>
   ```

### Mental Model

- **Local Git Commands** (commit, rebase, etc.): Use `git -c include.path={gitconfig}` + `GIT_COMMITTER_*` env vars. These affect the **author/committer metadata** on the commit objects.
- **GitHub Platform Operations** (push, PRs, API): Use the **Installation Access Token (IAT)**. These affect the **authentication and authorization** with GitHub. 

**CRITICAL**: `git push` is a platform interaction. Never rely on the system's global git credentials. Always use the IAT.

### Policies

- **Review Policy**: After creating a Pull Request, you MUST request a review from `@leonardo-zhu` and wait for explicit approval before merging.
- **PR Merge Policy**: Always use `merge_method: "rebase"` when merging PRs via API.

App ID and Installation ID are pre-configured in the MCP server environment — no manual input needed.

## Examples

Replace `{gitconfig}`, `{co-authored-by}`, and `<IAT>` with your values.

```bash
# 1. Commit/Rebase/Merge (Local operations - need gitconfig and committer env)
GIT_COMMITTER_NAME="leonardo-github-assist[bot]" \
GIT_COMMITTER_EMAIL="271226941+leonardo-github-assist[bot]@users.noreply.github.com" \
git -c include.path={gitconfig} commit \
  -m "feat: add feature" \
  -m "{co-authored-by}"

# Example for rebase/merge (sets committer)
GIT_COMMITTER_NAME="leonardo-github-assist[bot]" \
GIT_COMMITTER_EMAIL="271226941+leonardo-github-assist[bot]@users.noreply.github.com" \
git -c include.path={gitconfig} rebase origin/main

# 2. Push (Remote operation - needs IAT)
git push https://x-access-token:<IAT>@github.com/leonardo-zhu/agent-skills.git main
```
