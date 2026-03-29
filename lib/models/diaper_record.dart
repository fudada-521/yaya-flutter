import 'base_record.dart';

/// 换尿布记录数据模型
///
/// 记录宝宝换尿布的时间、类型和状态。
/// 类型（type）：wet-小便，dirty-大便，mixed-混合
/// 状态（status）：normal-正常，loose-稀便，hard-硬便，blood-带血
/// 提供健康状态判断：healthy（健康）、warning（警告）、danger（危险）
class DiaperRecord extends BaseRecord {
  final DateTime changeTime;
  final String type; // 'wet', 'dirty', 'mixed'
  final String status; // 'normal', 'loose', 'hard', 'blood'
  final String? notes;

  DiaperRecord({
    super.id,
    required super.babyId,
    required this.changeTime,
    required this.type,
    required this.status,
    this.notes,
    super.createdAt,
  });

  @override
  String get tableName => 'diaper_records';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'changeTime': changeTime.toIso8601String(),
      'type': type,
      'status': status,
      'notes': notes,
    });
    return map;
  }

  factory DiaperRecord.fromMap(Map<String, dynamic> map) {
    return DiaperRecord(
      id: map['id'],
      babyId: map['babyId'],
      changeTime: DateTime.parse(map['changeTime']),
      type: map['type'],
      status: map['status'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  DiaperRecord copyWith({
    String? id,
    String? babyId,
    DateTime? createdAt,
    DateTime? changeTime,
    String? type,
    String? status,
    String? notes,
  }) {
    return DiaperRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      createdAt: createdAt ?? this.createdAt,
      changeTime: changeTime ?? this.changeTime,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case 'wet':
        return '小便';
      case 'dirty':
        return '大便';
      case 'mixed':
        return '混合';
      default:
        return type;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'normal':
        return '正常';
      case 'loose':
        return '稀便';
      case 'hard':
        return '硬便';
      case 'blood':
        return '带血';
      default:
        return status;
    }
  }

  String get healthStatus {
    if (status == 'normal' || status == 'mixed') {
      return 'healthy';
    } else if (status == 'loose' || status == 'hard') {
      return 'warning';
    } else {
      return 'danger';
    }
  }
}
