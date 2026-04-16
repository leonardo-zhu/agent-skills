---
name: github-pr-merge
description: Check mergeability and rebase-merge a GitHub PR using IAT + REST API, then send a Telegram notification directly via Bot API. Use when a PR has been approved and needs to be merged automatically. Caller provides repo, pr number, pr_title, reviewer login, and IAT. Do NOT use gh CLI.
---

# GitHub PR Merge

## Critical constraints

- **No intermediate text output.** Stay completely silent until all steps are done.
- **No gh CLI.** Use `curl` with the provided IAT.
- **Send Telegram notification yourself** using the telegram-notify skill — do not rely on openclaw delivery.
- Do not retry on failure. Report and stop.

## Required inputs from caller

| Field | Example |
|-------|---------|
| `repo` | `leonardo-zhu/tab-out` |
| `pr` | `3` |
| `pr_title` | `"Add dark mode"` |
| `reviewer` | `leonardo-zhu` |
| `iat` | `ghs_xxxx` |

## Workflow

### 1. Check mergeability

```bash
curl -s \
  -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/pulls/<pr>
```

Proceed only if `mergeable == true` and `mergeable_state` is not `"blocked"` or `"dirty"`.

### 2. Rebase merge

```bash
curl -s -X PUT \
  -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/pulls/<pr>/merge \
  -d '{"merge_method":"rebase"}'
```

Success: HTTP 200, response contains `"merged": true`.

### 3. Send Telegram notification (telegram-notify skill)

**On success:**
```
🎉 <repo>#<pr> "<pr_title>" 已 rebase 合并！感谢 @<reviewer> 的 approve。
```

**On merge failure (not mergeable):**
```
⚠️ <repo>#<pr> 已 approve 但无法合并，原因：<mergeable_state 或 API 错误信息>。
```

### 4. Final log line (for main agent only)

```
[github-pr-merge] done: <repo>#<pr> — <merged|failed: reason>
```
