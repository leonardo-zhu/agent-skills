---
name: telegram-notify
description: Send a message directly to the user's Telegram chat via Bot API. Use this skill whenever an agent or subagent needs to notify the user on Telegram — bypassing openclaw's delivery mechanism. Suitable for webhook-triggered agents, subagents, or any background task that needs to push a result notification. Credentials are pre-configured; caller only provides the message text.
---

# Telegram Notify

Send a message to the user's Telegram chat directly via Bot API.

## Credentials (pre-configured)

The following environment variables are **already injected** into the agent's environment and you can get them directly.

- **Bot token**: `${TELEGRAM_BOT_TOKEN_GITHUB}`
- **Chat ID**: `${TELEGRAM_CHAT_ID}`

## Send a message

```bash
curl -s -X POST \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN_GITHUB}/sendMessage" \
  -d "chat_id=${TELEGRAM_CHAT_ID}&parse_mode=HTML&text=<message>"
```

- Use `parse_mode=HTML` for `<b>bold</b>` or `<code>inline code</code>`.
- Special HTML characters in message text must be escaped: `&` → `&amp;`, `<` → `&lt;`, `>` → `&gt;`.
- Max message length: 4096 characters.

## Message conventions

Keep messages short and scannable. Recommended format:

```
<emoji> <one-line summary>
```

Standard emoji prefixes:
| Situation | Emoji |
|-----------|-------|
| Success | ✅ 🎉 |
| Issues found | 🔍 |
| Incremental update | 🔄 |
| Warning / failed | ⚠️ |
| New item | 🆕 |
| Comment / reply | 💬 |

## Why use this instead of openclaw delivery

openclaw's `deliver: true` only delivers the agent's last text output before the first blocking operation (e.g. `sessions_spawn`). Subagents that resume after a blocking call will have their output silently dropped. Use this skill to send the notification yourself and ensure delivery.
