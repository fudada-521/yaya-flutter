import 'package:uuid/uuid.dart';

class DiaperRecord {
  final String id;
  final String babyId;
  final DateTime changeTime;
  final String type; // 'wet', 'dirty', 'mixed'
  final String status; // 'normal', 'loose', 'hard', 'blood'
  final String? notes;
  final DateTime createdAt;

  DiaperRecord({
    String? id,
    required this.babyId,
    required this.changeTime,
    required this.type,
    required this.status,
    this.notes,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'changeTime': changeTime.toIso8601String(),
      'type': type,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
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

  DiaperRecord copyWith({
    String? id,
    String? babyId,
    DateTime? changeTime,
    String? type,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return DiaperRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      changeTime: changeTime ?? this.changeTime,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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