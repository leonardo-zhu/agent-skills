# GitHub PR Review API Reference

## Post a COMMENT review (no issues found)

```bash
curl -s -X POST \
  -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/pulls/<pr>/reviews \
  -d '{"event":"COMMENT","body":"LGTM ✅ <中文原因>"}'
```

## Post REQUEST_CHANGES with inline comments (issues found)

```bash
curl -s -X POST \
  -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/pulls/<pr>/reviews \
  -d '{
    "event": "REQUEST_CHANGES",
    "body": "<中文总结>",
    "comments": [
      {
        "path": "<文件路径>",
        "line": <行号>,
        "body": "<中文评论>"
      }
    ]
  }'
```

### Inline comment requirements
- `path`: relative file path as returned in the files list (e.g. `src/utils/auth.ts`)
- `line`: must be a line number present in the diff (use the `+` side line number)
- `body`: Chinese only
- If multiple issues exist in the same file, include multiple objects in `comments`

## Fetch file content (for shared modules)

```bash
curl -s \
  -H "Authorization: Bearer <IAT>" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<repo>/contents/<path>?ref=<head_ref>
```

Response contains base64-encoded `content` field. Decode with:

```bash
echo "<content>" | base64 -d
```
