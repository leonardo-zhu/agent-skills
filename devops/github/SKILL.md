---
name: github
description: Use when performing remote operations on GitHub platform, including git push/fetch/pull, creating or merging pull requests, and interacting with GitHub APIs. Ensures correct use of Installation Access Tokens (IAT) and adherence to pull request and code review policies.
license: MIT
metadata:
  author: leonardo
  version: "1.0"
---

# GitHub Platform Operations

## Overview

This skill defines the standard procedures for interacting with GitHub. It ensures that all platform-level operations use the correct bot-based authentication and follow established organizational policies for code contributions.

## 1. Authentication (Installation Access Tokens)

Never use a personal Personal Access Token (PAT) for API calls or remote Git operations (push/pull/fetch). Always use the Installation Access Token (IAT).

### Authentication Flow

1.  **Get Token**: Call `mcp__gh-mcp__get_installation_token` to get an Installation Access Token (IAT).
2.  **API Calls**: Set `Authorization: Bearer <IAT>` for all REST/GraphQL requests.
3.  **Git Remote Ops**: Treat these as GitHub platform operations. Use the IAT in the URL to ensure the bot identity is used:

    ```bash
    git push https://x-access-token:<IAT>@github.com/<owner>/<repo>.git <branch>
    ```

## 2. Remote vs. Local Operations

| Type | Context | Tooling |
| :--- | :--- | :--- |
| **Local** | `commit`, `rebase`, `amend` | Use `git-identity` skill (local Metadata) |
| **Remote** | `push`, `pull`, API | Use `github` skill (IAT Authentication) |

**CRITICAL**: `git push` is a platform interaction. Never rely on the system's global git credentials. Always use the IAT.

## 3. Pull Request & Review Policies

When contributing code to GitHub repositories:

-   **Review Policy**: After creating a Pull Request, you MUST request a review from `@leonardo-zhu` and wait for explicit approval before merging.
-   **PR Merge Policy**: Always use `merge_method: "rebase"` when merging PRs via the API.
-   **Configuration**: App ID and Installation ID are pre-configured in the MCP server environment.

## 4. Examples

### Performing a Secure Push

```bash
# Replace <IAT> with the token from gh-mcp
git push https://x-access-token:<IAT>@github.com/leonardo-zhu/agent-skills.git main
```
