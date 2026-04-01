import 'base_record.dart';

/// 疫苗接种记录数据模型
///
/// 独立记录宝宝疫苗接种情况，包括：
/// - 疫苗名称
/// - 接种时间
/// - 接种状态
/// - 接种机构
/// - 疫苗批号
/// - 备注
class VaccineRecord extends BaseRecord {
  final DateTime vaccinationTime; // 接种时间
  final String vaccineName;       // 疫苗名称
  final String? vaccineCode;      // 疫苗代码（如 "HepB"）
  final String status;            // 状态: pending/completed/overdue
  final String? hospital;         // 接种机构
  final String? batchNumber;      // 疫苗批号
  final String? notes;           // 备注

  VaccineRecord({
    super.id,
    required super.babyId,
    required this.vaccinationTime,
    required this.vaccineName,
    this.vaccineCode,
    this.status = 'pending',
    this.hospital,
    this.batchNumber,
    this.notes,
    super.createdAt,
  });

  @override
  String get tableName => 'vaccine_records';

  /// 接种状态常量
  static const String statusPending = 'pending';     // 待接种
  static const String statusCompleted = 'completed'; // 已完成
  static const String statusOverdue = 'overdue';     // 已过期

  /// 获取状态显示名称
  String get statusDisplayName {
    switch (status) {
      case statusPending:
        return '待接种';
      case statusCompleted:
        return '已完成';
      case statusOverdue:
        return '已过期';
      default:
        return status;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'vaccinationTime': vaccinationTime.toIso8601String(),
      'vaccineName': vaccineName,
      'vaccineCode': vaccineCode,
      'status': status,
      'hospital': hospital,
      'batchNumber': batchNumber,
      'notes': notes,
    });
    return map;
  }

  factory VaccineRecord.fromMap(Map<String, dynamic> map) {
    return VaccineRecord(
      id: map['id'],
      babyId: map['babyId'],
      vaccinationTime: DateTime.parse(map['vaccinationTime']),
      vaccineName: map['vaccineName'],
      vaccineCode: map['vaccineCode'],
      status: map['status'] ?? statusPending,
      hospital: map['hospital'],
      batchNumber: map['batchNumber'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  VaccineRecord copyWith({
    String? id,
    String? babyId,
    DateTime? createdAt,
    DateTime? vaccinationTime,
    String? vaccineName,
    String? vaccineCode,
    String? status,
    String? hospital,
    String? batchNumber,
    String? notes,
  }) {
    return VaccineRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      createdAt: createdAt ?? this.createdAt,
      vaccinationTime: vaccinationTime ?? this.vaccinationTime,
      vaccineName: vaccineName ?? this.vaccineName,
      vaccineCode: vaccineCode ?? this.vaccineCode,
      status: status ?? this.status,
      hospital: hospital ?? this.hospital,
      batchNumber: batchNumber ?? this.batchNumber,
      notes: notes ?? this.notes,
    );
  }
}
