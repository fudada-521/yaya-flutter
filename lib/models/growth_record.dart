import 'package:uuid/uuid.dart';

class GrowthRecord {
  final String id;
  final String babyId;
  final DateTime recordDate;
  final double? height; // cm
  final double? weight; // kg
  final double? headCircumference; // cm
  final String? notes;
  final DateTime createdAt;

  GrowthRecord({
    String? id,
    required this.babyId,
    required this.recordDate,
    this.height,
    this.weight,
    this.headCircumference,
    this.notes,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'recordDate': recordDate.toIso8601String(),
      'height': height,
      'weight': weight,
      'headCircumference': headCircumference,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GrowthRecord.fromMap(Map<String, dynamic> map) {
    return GrowthRecord(
      id: map['id'],
      babyId: map['babyId'],
      recordDate: DateTime.parse(map['recordDate']),
      height: map['height']?.toDouble(),
      weight: map['weight']?.toDouble(),
      headCircumference: map['headCircumference']?.toDouble(),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  GrowthRecord copyWith({
    String? id,
    String? babyId,
    DateTime? recordDate,
    double? height,
    double? weight,
    double? headCircumference,
    String? notes,
    DateTime? createdAt,
  }) {
    return GrowthRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      recordDate: recordDate ?? this.recordDate,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      headCircumference: headCircumference ?? this.headCircumference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get ageInDays => recordDate.difference(DateTime.now()).inDays;
  int get ageInMonths => (recordDate.year - DateTime.now().year) * 12 + recordDate.month - DateTime.now().month;

  // 标准生长曲线参考值（WHO标准）
  double? get heightPercentile {
    if (height == null) return null;
    // 简化的参考值，实际应用中应该使用完整的生长曲线数据
    final age = ageInMonths;
    if (age < 0) return null;

    // 这里只是示例，实际应该使用专业的生长曲线数据库
    return 50.0; // 假设都是50百分位
  }

  double? get weightPercentile {
    if (weight == null) return null;
    // 简化的参考值
    final age = ageInMonths;
    if (age < 0) return null;

    return 50.0; // 假设都是50百分位
  }

  String get growthStatus {
    final hPercentile = heightPercentile;
    final wPercentile = weightPercentile;

    if (hPercentile == null || wPercentile == null) return 'unknown';

    if (hPercentile >= 3 && hPercentile <= 97 && wPercentile >= 3 && wPercentile <= 97) {
      return 'normal';
    } else if (hPercentile < 3 || wPercentile < 3) {
      return 'low';
    } else {
      return 'high';
    }
  }
}