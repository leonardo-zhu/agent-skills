---
name: github-pr-review
description: Perform a full or incremental GitHub PR review using IAT + REST/GraphQL API. Creates and updates the "OpenClaw Review" Check Run, posts inline review comments, and processes accumulated unresolved comment threads. Use when triggered by pull_request:opened/reopened (full) or check_run:rerequested (incremental). Do NOT use gh CLI. Caller must supply repo, pr number, pr_title, author, head_ref, IAT, and mode ("full" or "incremental").
---

# GitHub PR Review (OpenClaw Review)

## Critical constraints

- **No intermediate text output.** Every word you output is delivered to Telegram by the parent agent. Stay completely silent until all steps are done, then output one final log line only.
- **No gh CLI.** All GitHub operations use `curl` (REST) or GraphQL with the provided IAT.
- **Telegram notification is your responsibility.** Send it directly via Bot API at the end — do not rely on openclaw's delivery mechanism.
- All review bodies, inline comments, and thread replies must be in **Chinese**.

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

---

## Workflow

### 1. Set Check Run to "in_progress"

Get head SHA, then create the Check Run:

```bash
# Get head SHA
curl -s -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/pulls/<pr> | jq -r '.head.sha'

# Create Check Run
curl -s -X POST \
  -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/check-runs \
  -d '{"name":"OpenClaw Review","head_sha":"<head_sha>","status":"in_progress"}'
```

Save the returned `id` as `<check_run_id>`.

### 2. Fetch PR diff and changed files

```bash
# Diff
curl -s -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github.v3.diff" \
  https://api.github.com/repos/<repo>/pulls/<pr>

# Changed files
curl -s -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/pulls/<pr>/files
```

If any changed file is a shared module (utils / types / interfaces / base class / config / exports), fetch its full content. See [references/review-api.md](references/review-api.md).

### 3. Fetch existing reviews and open comment threads

```bash
# All submitted reviews (to understand what was previously flagged)
curl -s -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/pulls/<pr>/reviews

# All inline review comments
curl -s -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/pulls/<pr>/comments

# PR conversation comments
curl -s -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/issues/<pr>/comments
```

Identify threads where the last message is **not** from `leonardo-github-assist[bot]` — these need a response.

### 4. Code analysis

Review for: bugs, security, performance, error handling, readability, global impact.

- `mode=full`: review entire diff
- `mode=incremental`: focus only on new commits; cross-reference step 3 to avoid re-flagging already-addressed issues

### 5. Process unresolved comment threads

For each thread where last reply is not from `leonardo-github-assist[bot]`:

**Requires reasoning / code change:**
Reply with analysis, leave thread open.

```bash
curl -s -X POST \
  -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/pulls/<pr>/comments/<comment_id>/replies \
  -d '{"body":"<中文回复>"}'
```

**No action needed (acknowledged / already fixed / non-issue):**
Reply then resolve via GraphQL.

```bash
# Get thread node_id
curl -s -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/pulls/comments/<comment_id> \
  | jq -r '.node_id'

# Resolve thread
curl -s -X POST \
  -H "Authorization: Bearer <IAT>" \
  -H "Content-Type: application/json" \
  https://api.github.com/graphql \
  -d '{"query":"mutation { resolveReviewThread(input: { threadId: \"<node_id>\" }) { thread { isResolved } } }"}'
```

### 6. Post PR Review with inline comments

See [references/review-api.md](references/review-api.md) for APPROVE / COMMENT / REQUEST_CHANGES.

**Auto-approve rule:** `author == @leonardo-zhu` AND no issues found → `APPROVE`. All other no-issue cases → `COMMENT`.

### 7. Complete Check Run

**Issues found:**
```bash
curl -s -X PATCH \
  -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/check-runs/<check_run_id> \
  -d '{"status":"completed","conclusion":"action_required","output":{"title":"发现 N 个问题","summary":"<中文摘要>"}}'
```

**Clean:**
```bash
curl -s -X PATCH \
  -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/check-runs/<check_run_id> \
  -d '{"status":"completed","conclusion":"success","output":{"title":"审查通过","summary":"<中文摘要>"}}'
```

### 8. Send Telegram notification (via `telegram-notify` skill)

PR 链接统一使用 HTML 格式：`<a href="https://github.com/<repo>/pull/<pr>"><repo>#<pr></a>`

| 场景 | 格式 |
|---|---|
| Full，有问题 | `🔍 已审查 <a href="..."><repo>#<pr></a> "<pr_title>"，发现 N 个问题，关键：...` |
| Full，clean + auto-approved | `✅ 已审查并 approve <a href="..."><repo>#<pr></a> "<pr_title>"，代码无问题。` |
| Full，clean | `✅ 已审查 <a href="..."><repo>#<pr></a> "<pr_title>"，代码无问题，可以 approve。` |
| Incremental，有问题 | `🔄 增量审查 <a href="..."><repo>#<pr></a>，发现 N 个新问题，关键：...` |
| Incremental，clean | `🔄 增量审查 <a href="..."><repo>#<pr></a>，新改动无问题。` |
| 处理了评论（N > 0） | 末尾追加：`（处理 N 条评论，resolve M 条）` |

### 9. Final log line (for parent agent only)

```
[github-pr-review] done: <repo>#<pr> — <"N issues" / "clean" / "clean+approved"> — check: <success/action_required> — threads: <N replied, M resolved>
```
