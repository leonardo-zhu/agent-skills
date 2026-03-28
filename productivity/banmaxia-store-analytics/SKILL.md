---
name: banmaxia-store-analytics
description: Access daily store analytics for 斑马侠散酒铺 (Banmaxia Liquor Store). Fetch sales data, generate analysis reports, and save them. Use when asked about store performance, daily sales, revenue analysis, or generating store reports.
license: MIT
metadata:
  author: leonardo
  version: "1.0"
---

# 斑马侠散酒铺 - 门店数据分析

本地 API 服务运行在 `http://localhost:4927`。通过以下接口获取数据、分析、保存报告。

## 获取数据

### 日报数据（含同比对比）

```bash
curl http://localhost:4927/api/report/compare?date=YYYY-MM-DD
```

返回当天数据 + 日环比/周同比/月同比。不传 date 默认今天。

### 纯数据（不含对比）

```bash
curl http://localhost:4927/api/report/daily?date=YYYY-MM-DD
```

## 分析指引

### 日报分析维度

1. **营收核心**: 支付金额、营业收入、退款金额、客户数、订单数、客单价、笔单价、连带率
2. **趋势判断**: 日环比（vs 昨天）、周同比（vs 上周同日）、月同比（vs 上月同日）
3. **客户构成**: 会员 vs 非会员 vs 流水客的收入占比
4. **拉新**: 新增会员数及渠道来源

### 报告格式

生成的微信推送消息使用以下格式:

```
斑马侠散酒铺 · [月]月[日]日日报

营收：¥[金额] ([趋势])
客户：[数量]人 ([趋势])
订单：[数量]单
客单价：¥[金额] ([趋势])
连带率：[数值] ([趋势])
退款：¥[金额] ([数量]单)

会员贡献 [比例]%，非会员 [比例]%

[AI 分析摘要 - 2-3 句话的关键洞察和建议]
```

## 保存报告

分析完成后，将报告保存回系统：

```bash
curl -X POST http://localhost:4927/api/reports \
  -H "Content-Type: application/json" \
  -d '{
    "id": "YYYY-MM-DD-[source]",
    "date": "YYYY-MM-DD",
    "source": "claude",
    "title": "[月]月[日]日日报分析",
    "content": "报告正文..."
  }'
```

`source` 字段: 使用 `claude`（Claude Code）、`openclaw`（OpenClaw）、`manual`（手动）。

## 检查登录状态

```bash
curl http://localhost:4927/api/auth/status
```

返回 `{"valid": true/false}`。如果 `false`，提醒用户到 `http://localhost:4927/settings` 扫码更新。

## 查看历史报告

```bash
# 报告列表
curl http://localhost:4927/api/reports

# 单份报告
curl http://localhost:4927/api/reports/YYYY-MM-DD-source
```
