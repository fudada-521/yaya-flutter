# Yaya Diary 项目记忆

## 项目概述
婴儿日记 Flutter 应用，支持记录喂养、睡眠、尿布、成长等宝宝数据。

## 技术栈
- Flutter + Provider 状态管理
- SQLite 本地数据库
- 跨平台 (iOS/Android)

## 项目结构
```
lib/
├── main.dart
├── models/           # 数据模型
│   ├── baby.dart
│   ├── feeding_record.dart
│   ├── sleep_record.dart
│   ├── diaper_record.dart
│   └── growth_record.dart
├── providers/         # 状态管理
│   ├── baby_provider.dart
│   └── records_provider.dart
├── database/
│   └── database_helper.dart
├── screens/          # 页面
│   ├── home_screen.dart
│   ├── baby_profile_screen.dart
│   ├── feeding_screen.dart
│   ├── sleep_screen.dart
│   ├── diaper_screen.dart
│   ├── growth_screen.dart
│   └── record_bottom_sheet_helper.dart  # 统一的 BottomSheet 辅助类
└── widgets/
    └── empty_baby_card.dart  # 空状态卡片组件
```

## 已完成功能

### 1. 宝宝信息管理
- 添加/编辑/删除宝宝档案
- 宝宝信息包括：姓名、出生日期、性别、出生体重、出生身高、备注
- 支持多宝宝切换

### 2. 记录类型
- **喂养记录**: 母乳亲喂、母乳瓶喂、奶粉、辅食，支持量和时长记录
- **睡眠记录**: 午睡/夜间睡眠，质量和时长统计
- **尿布记录**: 小便、大便、混合类型
- **成长记录**: 身高、体重、头围

### 3. 通用组件
- `EmptyBabyCard`: 空状态卡片，用于无宝宝或无记录时的引导
- `RecordBottomSheetHelper`: 统一的 BottomSheet 辅助类，封装所有添加/编辑/删除对话框

### 4. 数据管理
- SQLite 本地存储
- 级联删除（删除宝宝时自动删除关联记录）
- 清除所有数据功能（用于测试）

## 待办/计划

### 近期
- [ ] 统一 BottomSheet 重构（进行中）
  - 将喂养、睡眠、尿布、成长页面的 BottomSheet 移到 RecordBottomSheetHelper
  - 目前 showAddBaby 已完成，其他编辑/删除待完成

### 中期
- [ ] 数据导出功能
- [ ] 数据统计图表
- [ ] 提醒功能（喂养提醒、睡眠提醒等）

### 长期
- [ ] 云同步
- [ ] 多设备同步
- [ ] 照片/视频记录

## 项目状态
- Git: main 分支，最新提交 db3e3ec
- 构建: 可正常运行
- 代码分析: 无错误（flutter analyze 通过）

## 最近修改记录

### 2026-03-28
- 完成 `RecordBottomSheetHelper.showAddBaby()` 方法
- 所有页面统一使用共享的添加宝宝 BottomSheet
- 清理 baby_profile_screen.dart 中的冗余代码

### 更早
- 创建 EmptyBabyCard 组件统一空状态 UI
- 修复删除宝宝后 UI 不刷新问题
- 实现级联删除功能
- 统一各页面 AppBar 样式
