import 'package:uuid/uuid.dart';

class FeedingRecord {
  final String id;
  final String babyId;
  final DateTime feedTime;
  final double? amount; // ml or g
  final String type; // 'breast', 'bottle', 'solid'
  final String? method; // 'left', 'right', 'mixed' for breast
  final String? notes;
  final DateTime createdAt;

  FeedingRecord({
    String? id,
    required this.babyId,
    required this.feedTime,
    this.amount,
    required this.type,
    this.method,
    this.notes,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'feedTime': feedTime.toIso8601String(),
      'amount': amount,
      'type': type,
      'method': method,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FeedingRecord.fromMap(Map<String, dynamic> map) {
    return FeedingRecord(
      id: map['id'],
      babyId: map['babyId'],
      feedTime: DateTime.parse(map['feedTime']),
      amount: map['amount']?.toDouble(),
      type: map['type'],
      method: map['method'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  FeedingRecord copyWith({
    String? id,
    String? babyId,
    DateTime? feedTime,
    double? amount,
    String? type,
    String? method,
    String? notes,
    DateTime? createdAt,
  }) {
    return FeedingRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      feedTime: feedTime ?? this.feedTime,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      method: method ?? this.method,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case 'breast':
        return '母乳';
      case 'bottle':
        return '奶粉';
      case 'solid':
        return '辅食';
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
      default:
        return method ?? '';
    }
  }
}