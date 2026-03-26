import 'package:uuid/uuid.dart';

class SleepRecord {
  final String id;
  final String babyId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? quality; // 1-5评分
  final String? notes;
  final DateTime createdAt;

  SleepRecord({
    String? id,
    required this.babyId,
    required this.startTime,
    this.endTime,
    this.quality,
    this.notes,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'quality': quality,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
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

  SleepRecord copyWith({
    String? id,
    String? babyId,
    DateTime? startTime,
    DateTime? endTime,
    int? quality,
    String? notes,
    DateTime? createdAt,
  }) {
    return SleepRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    return '$hours小时$minutes分钟';
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