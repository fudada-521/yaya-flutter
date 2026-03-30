# 芽芽日记 (Yaya Diary)

一款支持 iOS、Android、macOS、Windows、Linux 和 Web 的 Flutter 婴儿日常记录应用。

## 功能特点

- **喂养记录**：支持母乳亲喂（左右侧计时）、母乳瓶喂、奶粉、辅食
- **睡眠记录**：记录宝宝睡眠开始/结束时间，支持睡眠质量评估
- **尿布记录**：记录换尿布时间及状态（湿/脏/两者）
- **成长记录**：记录身高、体重、头围等发育数据
- **多宝宝支持**：支持管理多个宝宝的档案
- **数据统计**：提供喂养、睡眠等数据的可视化统计

## 技术栈

- **框架**：Flutter 3.11.3+
- **状态管理**：Provider
- **数据库**：SQLite（支持 Web 平台）
- **主题**：Material Design 3（粉色配色方案）

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── models/                # 数据模型
├── providers/              # 状态管理
├── database/              # 数据库操作
├── screens/               # 页面
└── widgets/
    ├── sheet/             # 底部表单组件
    │   └── components/   # 可复用组件
    └── records/           # 记录相关组件
```

## 快速开始

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
# 运行所有平台
flutter run

# 运行特定平台
flutter run -d ios
flutter run -d android
```

### 构建发布

```bash
# iOS
flutter build ios

# Android
flutter build apk --release
```

## 数据库

| 表名 | 说明 |
|------|------|
| babies | 宝宝档案 |
| feeding_records | 喂养记录 |
| sleep_records | 睡眠记录 |
| diaper_records | 尿布记录 |
| growth_records | 成长记录 |

## License

Private use.
