---
name: banmaxia-store-analytics
description: Access daily store analytics for 斑马侠散酒铺 (Banmaxia Liquor Store). Fetch sales data, generate analysis reports, and save them. Use when asked about store performance, daily sales, revenue analysis, or generating store reports.
license: MIT
metadata:
  author: leonardo
  version: "2.0"
---

# 斑马侠散酒铺 - 门店数据分析 Skill

本地 API 服务运行在 `http://localhost:4927`。

你是门店数据分析师。你的工作是：调用 API 获取真实数据 → 分析数据 → 生成报告 → 保存报告。

## 1. 获取数据

### 日报数据（含同比对比 + 7日趋势）

```bash
curl http://localhost:4927/api/report/compare?date=YYYY-MM-DD
```

不传 `date` 默认今天。返回结构：

```jsonc
{
  "date": "2026-03-29",
  "current": {
    "date": "2026-03-29",
    "storeName": "斑马侠散酒铺",
    "income": {
      "payAmount": 1370.14,       // 支付金额（元）
      "revenue": 1350.24,         // 营业收入 = 支付 - 退款
      "refundAmount": 19.90,      // 退款金额
      "payCustomerCount": 33,     // 支付客户数
      "payOrderCount": 38,        // 支付订单数
      "avgOrderAmount": 41.52,    // 客单价（每人平均消费）
      "avgTransactionAmount": 36.06, // 笔单价（每单平均）
      "avgItemPrice": 24.47,      // 件单价
      "jointRate": 1.7,           // 连带率（每笔订单平均商品数）
      "refundCustomerCount": 1,
      "refundOrderCount": 1,
      "customerBreakdown": {      // 客户类型收入构成
        "member": { "amount": 1370.14, "percentage": 100 },
        "nonMember": { "amount": 0, "percentage": 0 },
        "passerby": { "amount": 0, "percentage": 0 }
      }
    },
    "acquisition": {
      "newMemberCount": 2,        // 新增会员数
      "channelDistribution": {    // 渠道来源分布
        "门店": 2
      }
    },
    "repurchase": {
      "repurchaseRate": 15.5,     // 复购率 (%)
      "frequencyDistribution": {  // 复购频次分布
        "2次": 50, "3次": 30, "4次以上": 20
      },
      "cycleAnalysis": {          // 复购周期分布
        "7天内": 40, "7-14天": 35, "14-30天": 25
      }
    }
  },
  "comparison": {
    "dayOverDay": {               // 日环比（vs 昨天）
      "payAmount": { "value": 1200.00, "change": 0.1418, "direction": "up" },
      "revenue": { "value": 1180.00, "change": 0.1443, "direction": "up" },
      "payCustomerCount": { "value": 28, "change": 0.1786, "direction": "up" },
      "payOrderCount": { "value": 32, "change": 0.1875, "direction": "up" },
      "avgOrderAmount": { "value": 42.86, "change": -0.0313, "direction": "down" },
      "jointRate": { "value": 1.6, "change": 0.0625, "direction": "up" }
    },
    "weekOverWeek": { },          // 周同比（vs 上周同日），同上结构
    "monthOverMonth": { }         // 月同比（vs 上月同日），同上结构
  },
  "incomeTrend": [                // 近7日收入趋势
    { "date": "2026-03-23", "payAmount": 980.50 },
    { "date": "2026-03-24", "payAmount": 1120.00 }
  ]
}
```

**comparison 字段说明**：`change` 是小数（0.1418 = 14.18%），`direction` 为 up/down/flat，`value` 是对比日的值。

### 纯数据（不含对比和趋势）

```bash
curl http://localhost:4927/api/report/daily?date=YYYY-MM-DD
```

返回 `current` 部分的结构，适合只需要单日数据的场景。

## 2. 分析指引

### 日报分析（每日）

获取数据后，按以下维度逐一分析：

1. **营收概况**：今日支付金额、营业收入，与上周同日对比趋势
2. **效率指标**：客单价、笔单价、连带率的变化方向，判断经营质量
3. **客户构成**：会员/非会员/流水客占比，评估会员体系健康度
4. **拉新情况**：新增会员数及来源渠道
5. **退款异常**：退款金额和订单是否异常偏高
6. **趋势判断**：结合 7 日趋势，判断是上升/下降/波动

分析时注意：
- **周同比 > 日环比**：日环比波动大（周一 vs 周日没有可比性），优先看周同比
- **小店特征**：日均客户 20-50 人，单日波动正常，不要过度解读
- **连带率**：散酒铺连带率通常 1.5-2.5，低于 1.5 说明搭配销售不足
- **会员占比**：该店会员占比通常很高（>80%），非会员占比突然升高值得关注

### 周报/月报分析（深度）

需要更深入分析时，额外关注：

5. **复购分析**：复购率趋势、频次分布是否健康、复购周期是否稳定
6. **会员价值**：高频复购客户占比、新老会员消费差异
7. **经营建议**：基于数据给出 1-2 条可执行的建议

## 3. 生成报告

### 日报格式（微信推送用）

简洁，适合手机阅读：

```
斑马侠散酒铺 · [月]月[日]日日报

营收：¥[payAmount] ([周同比趋势])
客户：[payCustomerCount]人 ([周同比趋势])
订单：[payOrderCount]单
客单价：¥[avgOrderAmount] ([周同比趋势])
连带率：[jointRate] ([周同比趋势])
退款：¥[refundAmount] ([refundOrderCount]单)

会员贡献 [member.percentage]%，非会员 [nonMember.percentage]%
新增会员：[newMemberCount]人

📊 AI 分析
[2-4 句关键洞察，包含数据支撑和经营建议]
```

趋势格式：`↑12.5%` / `↓8.3%` / `持平`（change * 100，取绝对值，change > 0 用 ↑，< 0 用 ↓）

### 分析摘要写作要求

- **用数据说话**：每个判断都要有具体数字支撑
- **对比出洞察**：不只报数字，要说明「比上周同日增长/下降了多少」
- **给出建议**：至少 1 条可执行的经营建议
- **简洁直白**：店主不是数据分析师，用大白话，避免专业术语
- **2-4 句话**：不要写长篇大论

好的分析示例：
> 今日营收 ¥1,370，较上周四增长 56.6%，主要由会员消费驱动。客单价 ¥41.52（↑18.6%），连带率 1.7，说明顾客买的多了也买的贵了。建议关注周末客流变化，如果持续增长可以考虑增加散酒品类。

## 4. 保存报告

分析完成后**必须**保存报告：

```bash
curl -X POST http://localhost:4927/api/reports \
  -H "Content-Type: application/json" \
  -d '{
    "id": "YYYY-MM-DD-[source]",
    "date": "YYYY-MM-DD",
    "source": "claude",
    "title": "[月]月[日]日日报分析",
    "content": "完整报告正文..."
  }'
```

`source` 取值：
- `claude` — Claude Code 生成
- `openclaw` — OpenClaw 生成
- `manual` — 手动触发

## 5. 检查系统状态

```bash
curl http://localhost:4927/api/auth/status
```

返回 `{"valid": true/false, "reason": null/"expired"/"no_cookie"/"no_csrf_token"}`。

如果返回 `valid: false`，提醒用户：「有赞登录已失效，请手动更新 config.json 中的 cookie 和 csrfToken。」

## 6. 查看历史报告

```bash
# 报告列表（最新在前）
curl http://localhost:4927/api/reports

# 单份报告详情
curl http://localhost:4927/api/reports/YYYY-MM-DD-source
```

## 完整工作流

1. `GET /api/auth/status` → 确认登录有效
2. `GET /api/report/compare` → 获取今日数据 + 对比 + 趋势
3. 按分析指引生成报告
4. `POST /api/reports` → 保存报告
5. 如需推送微信，将报告内容发送给用户
