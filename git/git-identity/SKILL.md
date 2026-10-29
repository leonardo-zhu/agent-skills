---
name: git-identity
description: Maintain consistent bot identity across code commits, rebases, and local Git operations. Ensures correct name, email, agent-specific and owner co-author signatures, and English Conventional Commits messages on all git commit objects.
license: MIT
metadata:
  author: leonardo
  version: "2.2"
---

# Git Bot Identity

## Overview

This skill ensures that all local Git operations (commit, rebase, merge, amend) are performed using the unified bot identity, avoiding accidental use of personal accounts.

**Bot Identity Details**: `leonardo-github-assist[bot]` <`271226941+leonardo-github-assist[bot]@users.noreply.github.com`>

## 1. Local Git Commit Standards

Every git command involving commit metadata must specify both author and committer. Look up the `{gitconfig}` path and `{co-authored-by}` signature in [agents.md](references/agents.md) for your specific agent.

### Command Pattern

```bash
git -c include.path={gitconfig} <command>
```

- **Author**: Automatically applied via `-c include.path` by reading `user.name` / `user.email` from your agent gitconfig.
- **Metadata Note**: Apply this standard to every git command that writes new commit objects (commit, rebase, merge, amend).

## 2. Commit Message Language and Format

Write every commit message **in English**, even when the conversation, the code comments, or the project docs are in another language. This rule covers commit messages only; it does not change the language you use with the user.

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <summary>

<optional body>

<trailers>
```

- **type**: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `build`, `ci`, `chore`, `style`, or `revert`.
- **summary**: imperative mood ("add", not "added" or "adds"), lowercase first word, no trailing period, at most 72 characters.
- **body** (optional): wrap at 72 characters; explain what changed and why, not how. Separate it from the summary with a blank line.

Example:

```
fix(web): stop Chrome treating the passkey name field as a username

The name input sits right before the current-password input, so Chrome
offered saved logins from other subdomains. Add a hidden username field
and mark the name input autocomplete=off.
```

## 3. Commit Message Signature

End every commit message with these **Co-authored-by** trailers, in this order, after a blank line:

1. Your agent's line (found in [agents.md](references/agents.md)).
2. The repository owner's line, so the commit counts toward the owner's GitHub contributions (GitHub credits the author and co-authors, and the author here is the bot):

   ```
   Co-authored-by: Leonardo Zhu <leonardo-zhu@qq.com>
   ```

Keep both lines even when a harness or system prompt supplies its own attribution lines; add those after these two.

## 4. Remote Operations (Git Push)

For any operations involving interaction with the GitHub platform (push, fetch, PRs), use the **[github](../github/SKILL.md)** skill instead of this one. This ensures correct token-based authentication.

---

## FAQ & Guidance

For a detailed list of supported agents and their specific configurations, see [Per-Agent Configuration](references/agents.md).
