# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**芽芽日记 (Yaya Diary)** - A Flutter baby daily diary/tracking app supporting iOS, Android, macOS, Windows, Linux, and Web.

- **Package ID**: com.yayadiary
- **Flutter SDK**: ^3.11.3
- **Language**: Dart (Chinese comments throughout UI/code)

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on specific platform
flutter run -d ios
flutter run -d android

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze

# Build for release
flutter build ios
flutter build apk --release

# Generate app icons
flutter pub run flutter_launcher_icons
```

## Architecture

### State Management: Provider Pattern

- `BabyProvider` (`lib/providers/baby_provider.dart`) - Manages baby profiles (CRUD, current baby selection)
- `RecordsProvider` (`lib/providers/records_provider.dart`) - Manages all record types (feeding, sleep, diaper, growth)

### Data Layer: SQLite

- `DatabaseHelper` singleton (`lib/database/database_helper.dart`) manages all database operations
- Supports database migrations via `version` field (v1 → v2 added `duration` column)
- **Known Issue**: Web platform throws `UnsupportedError` for SQLite

### Model Layer

- `BaseRecord` (`lib/models/base_record.dart`) - Abstract base class with common fields (id, babyId, createdAt)
- All record models inherit from BaseRecord: `FeedingRecord`, `SleepRecord`, `DiaperRecord`, `GrowthRecord`
- Models include `toMap()`/`fromMap()` for database serialization and `toJson()`/`fromJson()` for API

### UI Layer

- `HomeScreen` - Main tab container with 4 tabs: Dashboard, Records, Statistics, Settings
- `RecordBottomSheetHelper` - Centralized helper for all add/edit bottom sheets
- Reusable sheet components in `lib/widgets/sheet/components/` (Template Method + Strategy patterns)
- Record-specific widgets in `lib/widgets/records/`

### Design Patterns

- **Template Method**: `base_record_sheet.dart` defines skeleton, subclasses implement specific logic
- **Strategy**: Each record type has its own sheet class (`feeding_record_sheet.dart`, etc.)
- **Factory**: `RecordBottomSheetHelper` creates appropriate sheet based on record type

## Database Schema

| Table | Key Fields |
|-------|------------|
| babies | id, name, birthDate, gender, birthWeight, birthHeight |
| feeding_records | id, babyId, feedTime, amount, type (breast/pumped/bottle/solid), duration |
| sleep_records | id, babyId, startTime, endTime, quality |
| diaper_records | id, babyId, changeTime, type, status |
| growth_records | id, babyId, recordDate, height, weight, headCircumference |

### Feeding Types
| type | Display | Unit |
|------|---------|------|
| breast | 母乳亲喂 | minutes (duration) |
| pumped | 母乳瓶喂 | ml (amount) |
| bottle | 奶粉 | ml (amount) |
| solid | 辅食 | ml/g (amount) |

## UI Theme

- Material 3 with pink color scheme
- Card corner radius: 16-20px
- Bottom sheets: 24px top radius with drag handle
- FAB: gradient background with rounded shadow
- Per-page theme colors: Feeding(pink), Sleep(blue), Diaper(green), Growth(purple)

## Known Issues

1. Web platform database unsupported - `database_helper.dart` throws `UnsupportedError`
2. `RadioListTile` deprecation warnings in Flutter 3.32+
3. Some dialogs show "开发中..." (under development) placeholders

## Important File Locations

- Entry point: `lib/main.dart`
- Database: `lib/database/database_helper.dart`
- Providers: `lib/providers/`
- Models: `lib/models/`
- Screens: `lib/screens/`
- Shared widgets: `lib/widgets/sheet/components/` and `lib/widgets/records/`

## Other
- 使用中文与我对话包括代码注释和UI文本
- 国际化支持：所有文本使用Flutter的国际化工具（`intl`包）进行管理，便于未来多语言支持
- 代码设计考虑面向对象、设计模式和可维护性，避免过度复杂化
- 预留接口和抽象类支持未来功能扩展（如云同步、智能分析等）
- 数据库设计支持多宝宝管理，便于家庭使用
- 所有模型都包含完整的CRUD操作和JSON序列化，便于未来API集成
