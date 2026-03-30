import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../models/baby.dart';
import '../models/feeding_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/growth_record.dart';

/// 备份数据格式版本
const int kBackupVersion = 1;

/// 备份数据结构
class BackupData {
  final int version;
  final DateTime createdAt;
  final String appVersion;
  final List<Map<String, dynamic>> babies;
  final List<Map<String, dynamic>> feedingRecords;
  final List<Map<String, dynamic>> sleepRecords;
  final List<Map<String, dynamic>> diaperRecords;
  final List<Map<String, dynamic>> growthRecords;

  BackupData({
    required this.version,
    required this.createdAt,
    required this.appVersion,
    required this.babies,
    required this.feedingRecords,
    required this.sleepRecords,
    required this.diaperRecords,
    required this.growthRecords,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'createdAt': createdAt.toIso8601String(),
    'appVersion': appVersion,
    'babies': babies,
    'feedingRecords': feedingRecords,
    'sleepRecords': sleepRecords,
    'diaperRecords': diaperRecords,
    'growthRecords': growthRecords,
  };

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      version: json['version'] ?? 1,
      createdAt: DateTime.parse(json['createdAt']),
      appVersion: json['appVersion'] ?? '1.0.0',
      babies: List<Map<String, dynamic>>.from(json['babies'] ?? []),
      feedingRecords: List<Map<String, dynamic>>.from(json['feedingRecords'] ?? []),
      sleepRecords: List<Map<String, dynamic>>.from(json['sleepRecords'] ?? []),
      diaperRecords: List<Map<String, dynamic>>.from(json['diaperRecords'] ?? []),
      growthRecords: List<Map<String, dynamic>>.from(json['growthRecords'] ?? []),
    );
  }
}

/// 备份服务
///
/// 提供数据备份和恢复功能：
/// - 备份：导出所有数据为 JSON 文件并分享
/// - 恢复：从备份文件导入数据
class BackupService {
  final DatabaseHelper _db = DatabaseHelper();

  /// 创建备份数据对象
  Future<BackupData> createBackupData() async {
    // 获取所有宝宝
    final babies = await _db.getBabies();
    final babiesData = babies.map((b) => b.toMap()).toList();

    // 获取所有记录
    final feedingRecords = await _db.getFeedingRecords();
    final sleepRecords = await _db.getSleepRecords();
    final diaperRecords = await _db.getDiaperRecords();
    final growthRecords = await _db.getGrowthRecords();

    return BackupData(
      version: kBackupVersion,
      createdAt: DateTime.now(),
      appVersion: '1.0.0',
      babies: babiesData,
      feedingRecords: feedingRecords.map((r) => r.toMap()).toList(),
      sleepRecords: sleepRecords.map((r) => r.toMap()).toList(),
      diaperRecords: diaperRecords.map((r) => r.toMap()).toList(),
      growthRecords: growthRecords.map((r) => r.toMap()).toList(),
    );
  }

  /// 备份数据并分享
  ///
  /// 将所有数据导出为 JSON 文件并通过系统分享界面分享
  Future<bool> backupAndShare() async {
    try {
      final backupData = await createBackupData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData.toJson());

      // 获取临时目录
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'yaya_diary_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      // 写入文件
      await file.writeAsString(jsonString);

      // 分享文件
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '芽芽日记备份',
        text: '来自芽芽日记的数据备份文件',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 从文件恢复数据
  ///
  /// 打开文件选择器，选择备份文件并恢复数据
  /// [clearExisting] 是否清除现有数据
  Future<RestoreResult> restoreFromFile({bool clearExisting = false}) async {
    try {
      // 选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return RestoreResult(success: false, message: '未选择文件');
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // 解析备份数据
      final backupData = BackupData.fromJson(json);

      // 验证备份数据
      if (backupData.babies.isEmpty) {
        return RestoreResult(success: false, message: '备份文件不包含宝宝数据');
      }

      // 执行恢复
      final restoreResult = await _restoreData(backupData, clearExisting: clearExisting);
      return restoreResult;
    } catch (e) {
      return RestoreResult(success: false, message: '恢复失败: ${e.toString()}');
    }
  }

  /// 执行数据恢复
  Future<RestoreResult> _restoreData(BackupData backupData, {bool clearExisting = false}) async {
    try {
      // 如果需要清除现有数据
      if (clearExisting) {
        await _db.clearAllData();
      }

      int babiesCount = 0;
      int recordsCount = 0;

      // 恢复宝宝数据
      for (final babyMap in backupData.babies) {
        // 检查宝宝是否已存在
        final existingBaby = await _db.getBabies();
        final exists = existingBaby.any((b) => b.id == babyMap['id']);
        if (!exists) {
          final baby = Baby.fromMap(babyMap);
          await _db.insertBaby(baby);
          babiesCount++;
        }
      }

      // 恢复喂养记录
      final existingFeedingRecords = await _db.getFeedingRecords();
      for (final recordMap in backupData.feedingRecords) {
        final exists = existingFeedingRecords.any((r) => r.id == recordMap['id']);
        if (!exists) {
          final record = FeedingRecord.fromMap(recordMap);
          await _db.insertFeedingRecord(record);
          recordsCount++;
        }
      }

      // 恢复睡眠记录
      final existingSleepRecords = await _db.getSleepRecords();
      for (final recordMap in backupData.sleepRecords) {
        final exists = existingSleepRecords.any((r) => r.id == recordMap['id']);
        if (!exists) {
          final record = SleepRecord.fromMap(recordMap);
          await _db.insertSleepRecord(record);
          recordsCount++;
        }
      }

      // 恢复尿布记录
      final existingDiaperRecords = await _db.getDiaperRecords();
      for (final recordMap in backupData.diaperRecords) {
        final exists = existingDiaperRecords.any((r) => r.id == recordMap['id']);
        if (!exists) {
          final record = DiaperRecord.fromMap(recordMap);
          await _db.insertDiaperRecord(record);
          recordsCount++;
        }
      }

      // 恢复成长记录
      final existingGrowthRecords = await _db.getGrowthRecords();
      for (final recordMap in backupData.growthRecords) {
        final exists = existingGrowthRecords.any((r) => r.id == recordMap['id']);
        if (!exists) {
          final record = GrowthRecord.fromMap(recordMap);
          await _db.insertGrowthRecord(record);
          recordsCount++;
        }
      }

      return RestoreResult(
        success: true,
        message: '成功恢复 $babiesCount 个宝宝和 $recordsCount 条记录',
        babiesCount: babiesCount,
        recordsCount: recordsCount,
      );
    } catch (e) {
      return RestoreResult(success: false, message: '恢复数据时出错: ${e.toString()}');
    }
  }

  /// 获取备份文件预览信息（不执行恢复）
  Future<BackupPreview?> getBackupPreview() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final backupData = BackupData.fromJson(json);

      return BackupPreview(
        createdAt: backupData.createdAt,
        appVersion: backupData.appVersion,
        babiesCount: backupData.babies.length,
        feedingRecordsCount: backupData.feedingRecords.length,
        sleepRecordsCount: backupData.sleepRecords.length,
        diaperRecordsCount: backupData.diaperRecords.length,
        growthRecordsCount: backupData.growthRecords.length,
      );
    } catch (e) {
      return null;
    }
  }
}

/// 恢复结果
class RestoreResult {
  final bool success;
  final String message;
  final int babiesCount;
  final int recordsCount;

  RestoreResult({
    required this.success,
    required this.message,
    this.babiesCount = 0,
    this.recordsCount = 0,
  });
}

/// 备份预览信息
class BackupPreview {
  final DateTime createdAt;
  final String appVersion;
  final int babiesCount;
  final int feedingRecordsCount;
  final int sleepRecordsCount;
  final int diaperRecordsCount;
  final int growthRecordsCount;

  int get totalRecords =>
      feedingRecordsCount + sleepRecordsCount + diaperRecordsCount + growthRecordsCount;

  BackupPreview({
    required this.createdAt,
    required this.appVersion,
    required this.babiesCount,
    required this.feedingRecordsCount,
    required this.sleepRecordsCount,
    required this.diaperRecordsCount,
    required this.growthRecordsCount,
  });
}
