---
name: github-pr-review
description: Perform a full or incremental GitHub PR code review using IAT + REST API, post the review result on GitHub, and send a Telegram notification directly via Bot API. Use when a subagent needs to review a pull request triggered by a GitHub webhook event (PR opened, reopened, or synchronized). Do NOT use gh CLI. Caller must supply repo, pr number, pr_title, author, head_ref, IAT, and mode ("full" or "incremental").
---

# GitHub PR Review

## Critical constraints

- **No intermediate text output.** Every word you output is delivered to Telegram by the parent agent. Stay completely silent until all steps are done, then output one final log line only.
- **No gh CLI.** All GitHub operations use `curl` with the provided IAT.
- **Telegram notification is your responsibility.** Send it directly via Bot API at the end — do not rely on openclaw's delivery mechanism.
- Review body and all inline comments must be in **Chinese**.

## Required inputs from caller

| Field | Example |
|-------|---------|
| `repo` | `leonardo-zhu/tab-out` |
| `pr` | `3` |
| `pr_title` | `"Add dark mode"` |
| `author` | `@alice` |
| `head_ref` | `feature/dark-mode` |
| `iat` | `ghs_xxxx` |
| `mode` | `full` or `incremental` |

## Workflow

### 1. Fetch PR diff

```bash
curl -s -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github.v3.diff" \
  https://api.github.com/repos/<repo>/pulls/<pr>
```

### 2. Fetch changed files

```bash
curl -s -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/pulls/<pr>/files
```

### 3. Deep analysis

- If `mode=incremental`: focus only on new changes, skip already-commented code.
- If any changed file is a shared module (utils / types / interfaces / base class / config / exports), fetch its full content:

```bash
curl -s -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/contents/<path>?ref=<head_ref>
```

Review for: bugs, security, performance, error handling, readability, global impact.

### 4. Post GitHub review

**Auto-approve rule:** If `author == @leonardo-zhu` AND no code-level issues found → use `APPROVE` event instead of `COMMENT`. In all other no-issue cases, use `COMMENT`.

See [references/review-api.md](references/review-api.md) for exact API calls for APPROVE, COMMENT, and REQUEST_CHANGES.

### 5. Send Telegram notification directly (Using `telegram-notify` skill)

Message format:
- Issues found: `🔍 已审查 <repo>#<pr> "<pr_title>"，发现 N 个问题，关键：...`
- Clean + auto-approved: `✅ 已审查并 approve <repo>#<pr> "<pr_title>"，代码无问题。`
- Clean (no auto-approve): `✅ 已审查 <repo>#<pr> "<pr_title>"，代码无问题，可以 approve。`
- Incremental (mode=incremental): replace `🔍` with `🔄`，prefix with `增量审查`

### 6. Final log line (for main agent only — NOT sent to Telegram)

After the Telegram send succeeds, output exactly one line:

```
[github-pr-review] done: <repo>#<pr> — <"N issues found" / "clean" / "clean+approved">
```
