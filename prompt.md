# 项目 25：共享汽车租赁 App（Flutter）

> 本文件仅描述需求，不包含任何实现代码。UI 使用 Material 基础组件，不做美化。

## 一、项目简介
短租/日租汽车租赁 C 端 App：车型浏览、网点取还车、时段计价、驾照认证 Mock、订单与押金、违章查询、发票申请、客服工单。Express Mock 实现计价与库存，Flutter Web 调试全流程。

## 二、技术栈

### 前端
- Flutter 3.22+ / Dart 3
- Riverpod + freezed
- go_router
- dio
- fl_chart（费用构成饼图）
- table_calendar（取还车日期）
- cached_network_image

### 后端 Mock
- Express + SQLite
- 端口 `3012`
- seed：车型、网点、可用库存日历

### Web 兼容约束
- **禁止**：geolocator、google_maps、camera、image_picker、蓝牙车钥匙 SDK
- **替代**：网点列表+城市筛选；驾照=表单 Mock 审核状态；取车码=6 位数字展示

## 三、后端 Mock API 设计

| 模块 | 路径 | 说明 |
|------|------|------|
| 认证 | `/api/auth/*` | |
| 车型 | GET `/api/vehicles` | 品牌、座位、变速箱筛选 |
| 车型 | GET `/api/vehicles/:id` | 详情、日租金、押金 |
| 网点 | GET `/api/locations` | 取还网点 |
| 库存 | GET `/api/availability` | 车型+网点+日期范围 |
| 报价 | POST `/api/quotes` | 租期、保险、总价 |
| 订单 | POST `/api/orders` | 下单锁库存 |
| 订单 | GET `/api/orders` | Tab 进行中/历史 |
| 订单 | POST `/api/orders/:id/cancel` | 阶梯违约金 |
| 订单 | POST `/api/orders/:id/pickup` | Mock 取车确认 |
| 订单 | POST `/api/orders/:id/return` | 还车结算 |
| 驾照 | GET/POST `/api/license` | 认证状态 pending/approved |
| 违章 | GET `/api/violations` | 关联订单 |
| 发票 | POST `/api/invoices` | |
| 工单 | CRUD `/api/tickets` | |
| 优惠券 | GET `/api/coupons` | |

**业务规则**
- 租期最少 4 小时，按小时+日混合计价 Mock
- 取消：取车前 24h 外全额退；24h 内扣 20%
- 库存：下单事务锁定；超时未支付 15 分钟释放
- 驾照未通过不可下单

## 四、页面清单（≥22 页）

| 序号 | 页面 | 路由 | 说明 |
|------|------|------|------|
| 1 | 启动 | `/splash` | |
| 2 | 登录 | `/login` | |
| 3 | 首页 | `/home` | 快捷租、banner |
| 4 | 选车 | `/vehicles` | 筛选排序 |
| 5 | 车型详情 | `/vehicle/:id` | |
| 6 | 选网点 | `/locations` | 取车/还车 |
| 7 | 选日期 | `/rental/dates` | calendar |
| 8 | 报价页 | `/quote` | 保险选项 |
| 9 | 确认订单 | `/order/confirm` | |
| 10 | 支付结果 | `/pay-result` | Mock |
| 11 | 订单列表 | `/orders` | |
| 12 | 订单详情 | `/order/:id` | 取还码、状态轴 |
| 13 | 取车确认 | `/order/:id/pickup` | |
| 14 | 还车结算 | `/order/:id/return` | 超时费、油费 Mock |
| 15 | 驾照认证 | `/license` | 表单+状态 |
| 16 | 违章列表 | `/violations` | |
| 17 | 违章详情 | `/violation/:id` | |
| 18 | 发票申请 | `/invoices/apply` | |
| 19 | 发票记录 | `/invoices` | |
| 20 | 优惠券 | `/coupons` | |
| 21 | 客服工单 | `/tickets` | |
| 22 | 创建工单 | `/ticket/create` | |
| 23 | 消息 | `/messages` | |
| 24 | 个人中心 | `/profile` | |
| 25 | 设置 | `/settings` | |

**底部导航**：首页 | 订单 | 我的

## 五、核心功能需求
1. 报价页：租期变化实时 POST quotes
2. 库存日历：不可用日期置灰
3. 订单状态机：待支付→待取车→使用中→待还车→已完成
4. 还车结算：展示费用明细 fl_chart
5. Web API_BASE=`http://localhost:3012`

## 六、编译与调试
```bash
cd backend && npm run dev    # :3012
flutter run -d chrome --web-port=5182 --dart-define=API_BASE=http://localhost:3012
```

## 七、交付物
- 前后端、seed（≥15 车型、≥8 网点、30 天库存）
- 测试：库存锁、取消违约金、驾照拦截
- README

## 八、本次任务
**只列出需求和架构规划，不要写代码。**
请输出：
1. 租车报价与库存模块划分
2. 混合计价（小时+日）算法说明
3. 订单状态机与取还车流程
4. go_router 深链（订单详情）
5. SQLite 表设计
6. Web 端日历组件注意点
