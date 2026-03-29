import 'package:uuid/uuid.dart';

/// 记录模型基类
///
/// 所有记录类型（喂养、睡眠、尿布、成长）都继承自此类。
/// 提供通用字段：id（唯一标识）、babyId（关联宝宝ID）、createdAt（创建时间）
/// 以及共享的序列化逻辑。
abstract class BaseRecord {
  final String id;
  final String babyId;
  final DateTime createdAt;

  BaseRecord({
    String? id,
    required this.babyId,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Converts record to Map for database storage.
  /// Subclasses should override and call super.toMap() then add extra fields.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields.
  /// Subclasses should override and call super.copyWith() then add extra fields.
  BaseRecord copyWith({
    String? id,
    String? babyId,
    DateTime? createdAt,
  });

  /// The database table name for this record type.
  String get tableName;
}
