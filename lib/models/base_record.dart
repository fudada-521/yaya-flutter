import 'package:uuid/uuid.dart';

/// Base class for all record types.
/// Provides common fields: id, babyId, createdAt
/// and shared serialization logic.
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
