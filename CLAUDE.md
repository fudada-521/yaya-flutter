# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在此仓库中处理代码时提供指导。
使用中文与我对话，包括代码注释

## 项目概述

**芽芽日记 (Yaya Diary)** - 一个支持 iOS、Android、macOS、Windows、Linux 和 Web 的 Flutter 婴儿日常日记/跟踪应用。

- **包 ID**: com.yayadiary
- **Flutter SDK**: ^3.11.3
- **语言**: Dart (UI/代码中全程使用中文注释)

## 常见命令

```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run

# 在特定平台上运行
flutter run -d ios
flutter run -d android

# 运行测试
flutter test

# 运行单个测试文件
flutter test test/widget_test.dart

# 分析代码
flutter analyze

# 构建发布版本
flutter build ios
flutter build apk --release

# 生成应用图标
flutter pub run flutter_launcher_icons
```

## 项目原则
- 国际化支持：所有文本使用Flutter的国际化工具（`intl`包）进行管理，便于未来多语言支持
- 代码设计考虑面向对象、设计模式和可维护性，避免过度复杂化
- 预留接口和抽象类支持未来功能扩展（如云同步、智能分析等）
- 数据库设计支持多宝宝管理，便于家庭使用
- 所有模型都包含完整的CRUD操作和JSON序列化，便于未来API集成

## 编译和热启动
- 使用 `flutter run` 启动应用，支持热重载和热重启
- 在开发完成一个功能后，使用热重载快速查看更改
- 在进行重大更改后，使用热重启确保状态重置

## 架构

### 状态管理：Provider 模式

- `BabyProvider` (`lib/providers/baby_provider.dart`) - 管理婴儿档案 (CRUD, 当前婴儿选择)
- `RecordsProvider` (`lib/providers/records_provider.dart`) - 管理所有记录类型 (喂养, 睡眠, 尿布, 成长, 辅食)
- `VaccineProvider` (`lib/providers/vaccine_provider.dart`) - 管理疫苗接种记录和提醒

### 数据层：SQLite

- `DatabaseHelper` 单例 (`lib/database/database_helper.dart`) 管理所有数据库操作
- 通过 `version` 字段支持数据库迁移 (v1 → v2 → v3 → v4 → v5)
- **已知问题**: Web 平台抛出 `UnsupportedError` 用于 SQLite

### 模型层

- `BaseRecord` (`lib/models/base_record.dart`) - 抽象基类，具有通用字段 (id, babyId, createdAt)
- 所有记录模型继承自 BaseRecord: `FeedingRecord`, `SleepRecord`, `DiaperRecord`, `GrowthRecord`, `SolidFoodRecord`, `VaccineRecord`
- 模型包括 `toMap()`/`fromMap()` 用于数据库序列化和 `toJson()`/`fromJson()` 用于 API

### 服务层

- `ThemeService` (`lib/services/theme_service.dart`) - 主题设置管理
- `FoodIngredientService` (`lib/services/food_ingredient_service.dart`) - 食材列表管理，支持自定义食材持久化
- `VaccineScheduleService` (`lib/services/vaccine_schedule_service.dart`) - 疫苗接种时间计算服务
- `NotificationService` (`lib/services/notification_service.dart`) - 本地通知服务，支持喂养、睡眠、尿布、疫苗提醒

### UI 层

- `HomeScreen` - 主要标签容器，包含 4 个标签：仪表板、记录、统计、设置
- `RecordBottomSheetHelper` - 所有添加/编辑底部表单的集中助手
- 可重用表单组件在 `lib/widgets/sheet/components/` (模板方法 + 策略模式)
- 记录特定小部件在 `lib/widgets/records/`

### 设计模式

- 代码设计遵循面向对象原则，使用抽象类和接口进行解耦，遵行单一职责原则、开放封闭原则等
- **模板方法**: `base_record_sheet.dart` 定义骨架，子类实现特定逻辑
- **策略**: 每种记录类型有自己的表单类 (`feeding_record_sheet.dart` 等)
- **工厂**: `RecordBottomSheetHelper` 根据记录类型创建适当的表单

## 数据库模式

| 表 | 关键字段 |
|-------|------------|
| babies | id, name, birthDate, gender, birthWeight, birthHeight |
| feeding_records | id, babyId, feedTime, amount, type (breast/pumped/bottle), duration |
| sleep_records | id, babyId, startTime, endTime, quality |
| diaper_records | id, babyId, changeTime, type, status |
| growth_records | id, babyId, recordDate, height, weight, headCircumference |
| solid_food_records | id, babyId, mealTime, foodName, amount, texture, ingredients, notes |
| vaccine_records | id, babyId, vaccinationTime, vaccineName, vaccineCode, status, hospital, batchNumber, notes |

### 喂养类型
| 类型 | 显示 | 单位 |
|------|---------|------|
| breast | 母乳亲喂 | 分钟 (持续时间) |
| pumped | 母乳瓶喂 | ml (数量) |
| bottle | 奶粉 | ml (数量) |

### 辅食质地类型
| 类型 | 显示 | 图标 |
|------|---------|------|
| puree | 泥糊 | 🫧 |
| soft | 软烂 | 🥣 |
| piece | 小块 | 🍖 |
| solid | 固体 | 🍽️ |

### 食材管理
- 默认食材：米粉、南瓜、胡萝卜、土豆、苹果、香蕉、鸡肉、蛋黄
- 支持自定义添加/删除食材
- 食材列表通过 `SharedPreferences` 持久化 (`food_ingredients` key)

### 疫苗接种
- 内置中国国家免疫规划11种免费疫苗（共22剂次）
- 疫苗列表：乙肝、卡介苗、脊灰、百白破、麻腮风、乙脑、A群流脑、A+C群流脑、甲肝、白破
- 根据宝宝出生日期自动计算各疫苗应接种时间
- 支持接种记录（已完成/待接种/已过期状态）
- 支持接种提醒（提前1天上午9点通知）
- 独立的疫苗接种计划页面，按月龄显示所有疫苗安排

## UI 主题

- Material 3 搭配粉色配色方案
- 卡片圆角半径：16-20px
- 底部表单：顶部 24px 圆角，带拖拽手柄
- FAB：渐变背景，带圆角阴影
- 每页主题颜色：喂养(粉色), 睡眠(蓝色), 尿布(绿色), 成长(紫色), 疫苗(蓝绿色)

## 已知问题

1. Web 平台不支持数据库 - `database_helper.dart` 抛出 `UnsupportedError`
2. Flutter 3.32+ 中 `RadioListTile` 弃用警告
3. 某些对话框显示 "开发中..." (开发中) 占位符

## 重要文件位置

- 入口点: `lib/main.dart`
- 数据库: `lib/database/database_helper.dart`
- 提供者: `lib/providers/`
- 模型: `lib/models/`
- 屏幕: `lib/screens/`
- 共享小部件: `lib/widgets/sheet/components/` 和 `lib/widgets/records/`
