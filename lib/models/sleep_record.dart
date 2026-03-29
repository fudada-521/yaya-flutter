import 'base_record.dart';

/// 睡眠记录数据模型
///
/// 记录宝宝睡眠开始时间、结束时间（可选）和睡眠质量评分（1-5分）。
/// 自动计算睡眠时长，并提供睡眠类型判断（上午小睡/下午小睡/晚上睡眠/夜间睡眠）。
/// 睡眠质量评分：1-很差，2-较差，3-一般，4-良好，5-优秀。
class SleepRecord extends BaseRecord {
  final DateTime startTime;
  final DateTime? endTime;
  final int? quality; // 1-5评分
  final String? notes;

  SleepRecord({
    super.id,
    required super.babyId,
    required this.startTime,
    this.endTime,
    this.quality,
    this.notes,
    super.createdAt,
  });

  @override
  String get tableName => 'sleep_records';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'quality': quality,
      'notes': notes,
    });
    return map;
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      id: map['id'],
      babyId: map['babyId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      quality: map['quality'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  SleepRecord copyWith({
    String? id,
    String? babyId,
    DateTime? createdAt,
    DateTime? startTime,
    DateTime? endTime,
    int? quality,
    String? notes,
  }) {
    return SleepRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
    );
  }

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  String? get durationString {
    final dur = duration;
    if (dur == null) return null;
    final hours = dur.inHours;
    final minutes = dur.inMinutes % 60;
    return '$hours 小时 $minutes 分钟';
  }

  String get qualityString {
    switch (quality) {
      case 1:
        return '很差';
      case 2:
        return '较差';
      case 3:
        return '一般';
      case 4:
        return '良好';
      case 5:
        return '优秀';
      default:
        return '未知';
    }
  }

  String get type {
    final hour = startTime.hour;
    if (hour >= 6 && hour < 12) {
      return '上午小睡';
    } else if (hour >= 12 && hour < 18) {
      return '下午小睡';
    } else if (hour >= 18 && hour < 24) {
      return '晚上睡眠';
    } else {
      return '夜间睡眠';
    }
  }
}
