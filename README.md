# 共享汽车租赁 App

短租/日租汽车租赁 C 端 App：车型浏览、网点取还车、时段计价、驾照认证 Mock、订单与押金、违章查询、发票申请、客服工单。Express Mock 后端 + Flutter Web 调试。

## 技术栈

| 层 | 技术 |
|---|---|
| 前端 | Flutter 3.22+、Riverpod、go_router、dio、table_calendar、fl_chart、cached_network_image |
| 后端 Mock | Express + better-sqlite3，端口 **3012** |

## 测试账号

| 手机号 | 密码 |
|--------|------|
| 13800138000 | 123456 |

## 快速开始

### 1. 启动 Mock 后端

```bash
cd backend
npm install
npm run dev
```

服务地址：`http://localhost:3012`

### 2. Web 调试 Flutter

```bash
cd mobile
flutter pub get
flutter run -d chrome --web-port=5182 --dart-define=API_BASE=http://localhost:3012
```

## 路由（25 页）

| 路由 | 页面 |
|------|------|
| `/splash` | 启动 |
| `/login` | 登录 |
| `/home` | 首页（Tab） |
| `/vehicles` | 选车 |
| `/vehicle/:id` | 车型详情 |
| `/locations` | 选网点 |
| `/rental/dates` | 选日期 |
| `/quote` | 报价 |
| `/order/confirm` | 确认订单 |
| `/pay-result` | 支付 Mock |
| `/orders` | 订单列表（Tab） |
| `/order/:id` | 订单详情（深链） |
| `/order/:id/pickup` | 取车确认 |
| `/order/:id/return` | 还车结算 |
| `/license` | 驾照认证 |
| `/violations` | 违章列表 |
| `/violation/:id` | 违章详情 |
| `/invoices/apply` | 发票申请 |
| `/invoices` | 发票记录 |
| `/coupons` | 优惠券 |
| `/tickets` | 客服工单 |
| `/ticket/create` | 创建工单 |
| `/messages` | 消息 |
| `/profile` | 个人中心（Tab） |
| `/settings` | 设置 |

**底部导航**：首页 | 订单 | 我的

## 业务规则（Mock）

- **租期**：最少 4 小时；按整天 + 剩余小时混合计价
- **取消**：取车前 24 小时外全额退；24 小时内扣 20% 违约金
- **库存**：下单事务锁定；待支付超过 15 分钟自动释放
- **驾照**：未通过认证不可下单

## 测试

```bash
cd backend && npm test
cd mobile && flutter test
```

覆盖：库存锁、取消违约金、驾照拦截。

## Seed 数据

- 29 款车型、16 个网点（8 城 × 2）
- 30 天库存日历
- 优惠券、消息、违章 Mock
