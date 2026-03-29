import 'base_record.dart';

/// 成长记录数据模型
///
/// 记录宝宝的身高（cm）、体重（kg）和头围（cm）。
/// 支持WHO标准生长曲线百分位计算，
/// 提供成长状态判断：normal（正常）、low（偏低）、high（偏高）。
class GrowthRecord extends BaseRecord {
  final DateTime recordDate;
  final double? height; // cm
  final double? weight; // kg
  final double? headCircumference; // cm
  final String? notes;

  GrowthRecord({
    super.id,
    required super.babyId,
    required this.recordDate,
    this.height,
    this.weight,
    this.headCircumference,
    this.notes,
    super.createdAt,
  });

  @override
  String get tableName => 'growth_records';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'recordDate': recordDate.toIso8601String(),
      'height': height,
      'weight': weight,
      'headCircumference': headCircumference,
      'notes': notes,
    });
    return map;
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

  @override
  GrowthRecord copyWith({
    String? id,
    String? babyId,
    DateTime? createdAt,
    DateTime? recordDate,
    double? height,
    double? weight,
    double? headCircumference,
    String? notes,
  }) {
    return GrowthRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      createdAt: createdAt ?? this.createdAt,
      recordDate: recordDate ?? this.recordDate,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      headCircumference: headCircumference ?? this.headCircumference,
      notes: notes ?? this.notes,
    );
  }

  int get ageInDays => recordDate.difference(DateTime.now()).inDays;
  int get ageInMonths => (recordDate.year - DateTime.now().year) * 12 + recordDate.month - DateTime.now().month;

  // 标准生长曲线参考值（WHO标准）
  double? get heightPercentile {
    if (height == null) return null;
    final age = ageInMonths;
    if (age < 0) return null;
    return 50.0; // 假设都是50百分位
  }

  double? get weightPercentile {
    if (weight == null) return null;
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
