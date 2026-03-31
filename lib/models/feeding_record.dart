import 'base_record.dart';

/// 喂养记录数据模型
///
/// 支持三种喂养类型：
/// - breast：母乳亲喂（记录时长，分钟）
/// - pumped：母乳瓶喂（记录奶量，ml）
/// - bottle：奶粉（记录奶量，ml）
///
/// 母乳亲喂可额外记录左侧/右侧/混合时长。
class FeedingRecord extends BaseRecord {
  final DateTime feedTime;
  final double? amount; // ml or g
  final String type; // 'breast', 'pumped', 'bottle'
  final String? method; // 'left', 'right', 'mixed', 'both' for breast
  final int? duration; // 总时长（分钟），兼容旧数据
  final int? leftDuration;      // 左侧时长（分钟）
  final int? rightDuration;     // 右侧时长（分钟）
  final int? mixedDuration;      // 混合时长（分钟，无法区分左右时）
  final String? notes;

  FeedingRecord({
    super.id,
    required super.babyId,
    required this.feedTime,
    this.amount,
    required this.type,
    this.method,
    this.duration,
    this.leftDuration,
    this.rightDuration,
    this.mixedDuration,
    this.notes,
    super.createdAt,
  });

  @override
  String get tableName => 'feeding_records';

  /// 计算总时长
  int get totalDuration {
    return (leftDuration ?? 0) + (rightDuration ?? 0) + (mixedDuration ?? 0) + (duration ?? 0);
  }

  /// 获取显示方式
  /// - 'both': 左右都喂了
  /// - 'left': 只喂左侧
  /// - 'right': 只喂右侧
  /// - 'mixed': 混合（无法区分）
  String get breastMethodDisplay {
    // 如果是混合
    if (mixedDuration != null && mixedDuration! > 0) {
      return '混合';
    }
    // 如果左右都有
    if (leftDuration != null && rightDuration != null) {
      if (leftDuration! > 0 && rightDuration! > 0) {
        return '左右';
      }
    }
    // 如果只有一侧
    if (leftDuration != null && leftDuration! > 0) {
      return '左侧';
    }
    if (rightDuration != null && rightDuration! > 0) {
      return '右侧';
    }
    // 兼容旧的 method 字段
    switch (method) {
      case 'left':
        return '左侧';
      case 'right':
        return '右侧';
      case 'mixed':
        return '混合';
      case 'both':
        return '左右';
      default:
        return method ?? '母乳亲喂';
    }
  }

  /// 获取时长显示描述
  String get durationSummary {
    final total = totalDuration;
    if (total == 0) return '';

    // 如果有混合时长
    if (mixedDuration != null && mixedDuration! > 0) {
      return '共 ${_formatDuration(total)}';
    }

    // 如果左右都有
    if (leftDuration != null && rightDuration != null) {
      if (leftDuration! > 0 && rightDuration! > 0) {
        return '共 ${_formatDuration(total)}（左${_formatDuration(leftDuration!)}，右${_formatDuration(rightDuration!)})';
      }
    }

    // 如果只有一侧
    if (leftDuration != null && leftDuration! > 0) {
      return '共 ${_formatDuration(total)}';
    }
    if (rightDuration != null && rightDuration! > 0) {
      return '共 ${_formatDuration(total)}';
    }

    // 兼容旧数据（可能是分钟，需要转换）
    return '共 ${_formatDuration(total)}';
  }

  String _formatDuration(int seconds) {
    // 秒数格式化
    if (seconds < 60) {
      return '${seconds}秒';
    }
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      if (secs > 0) {
        return '${h}h${m}m${secs}秒';
      }
      return m > 0 ? '${h}h${m}m' : '${h}h';
    }
    if (secs > 0) {
      return '${minutes}m${secs}秒';
    }
    return '${minutes}m';
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'feedTime': feedTime.toIso8601String(),
      'amount': amount,
      'type': type,
      'method': method,
      'duration': duration,
      'left_duration': leftDuration,
      'right_duration': rightDuration,
      'mixed_duration': mixedDuration,
      'notes': notes,
    });
    return map;
  }

  factory FeedingRecord.fromMap(Map<String, dynamic> map) {
    return FeedingRecord(
      id: map['id'],
      babyId: map['babyId'],
      feedTime: DateTime.parse(map['feedTime']),
      amount: map['amount']?.toDouble(),
      type: map['type'],
      method: map['method'],
      duration: map['duration'],
      leftDuration: map['left_duration'],
      rightDuration: map['right_duration'],
      mixedDuration: map['mixed_duration'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  FeedingRecord copyWith({
    String? id,
    String? babyId,
    DateTime? createdAt,
    DateTime? feedTime,
    double? amount,
    String? type,
    String? method,
    int? duration,
    int? leftDuration,
    int? rightDuration,
    int? mixedDuration,
    String? notes,
  }) {
    return FeedingRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      createdAt: createdAt ?? this.createdAt,
      feedTime: feedTime ?? this.feedTime,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      method: method ?? this.method,
      duration: duration ?? this.duration,
      leftDuration: leftDuration ?? this.leftDuration,
      rightDuration: rightDuration ?? this.rightDuration,
      mixedDuration: mixedDuration ?? this.mixedDuration,
      notes: notes ?? this.notes,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case 'breast':
        return '母乳亲喂';
      case 'pumped':
        return '母乳瓶喂';
      case 'bottle':
        return '奶粉';
      default:
        return type;
    }
  }

  String get methodDisplayName {
    switch (method) {
      case 'left':
        return '左侧';
      case 'right':
        return '右侧';
      case 'mixed':
        return '混合';
      case 'both':
        return '左右';
      default:
        return method ?? '';
    }
  }

  String get durationDisplayName {
    final total = totalDuration;
    if (total == 0) return '';
    final hours = total ~/ 60;
    final minutes = total % 60;
    if (hours > 0) {
      return '$hours 小时 $minutes 分钟';
    }
    return '$minutes 分钟';
  }
}
