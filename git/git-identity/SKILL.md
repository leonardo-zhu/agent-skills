---
name: git-identity
description: Maintain consistent bot identity across code commits, rebases, and local Git operations. Ensures correct name, email, and agent-specific signatures are applied to all git commit objects.
license: MIT
metadata:
  author: leonardo
  version: "2.1"
---

# Git Bot Identity

## Overview

This skill ensures that all local Git operations (commit, rebase, merge, amend) are performed using the unified bot identity, avoiding accidental use of personal accounts.

**Bot Identity Details**: `leonardo-github-assist[bot]` <`271226941+leonardo-github-assist[bot]@users.noreply.github.com`>

## 1. Local Git Commit Standards

Every git command involving commit metadata must specify both author and committer. Look up the `{gitconfig}` path and `{co-authored-by}` signature in [agents.md](references/agents.md) for your specific agent.

### Command Pattern

```bash
GIT_COMMITTER_NAME="leonardo-github-assist[bot]" \
GIT_COMMITTER_EMAIL="271226941+leonardo-github-assist[bot]@users.noreply.github.com" \
git -c include.path={gitconfig} <command>
```

- **Author**: Automatically applied via `-c include.path` by reading `user.name` / `user.email` from your agent gitconfig.
- **Committer**: Explicitly set via `GIT_COMMITTER_*` environment variables.
- **Metadata Note**: Apply this standard to every git command that writes new commit objects (commit, rebase, merge, amend).

## 2. Commit Message Signature

Append your agent's **Co-authored-by** line (found in [agents.md](references/agents.md)) to every commit message.

## 3. Remote Operations (Git Push)

For any operations involving interaction with the GitHub platform (push, fetch, PRs), use the **[github](../github/SKILL.md)** skill instead of this one. This ensures correct token-based authentication.

---

## FAQ & Guidance

For a detailed list of supported agents and their specific configurations, see [Per-Agent Configuration](references/agents.md).
