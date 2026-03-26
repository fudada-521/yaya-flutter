import 'package:uuid/uuid.dart';

class Baby {
  final String id;
  final String name;
  final String? avatar;
  final DateTime birthDate;
  final String gender; // 'male' or 'female'
  final double? birthWeight;
  final double? birthHeight;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Baby({
    String? id,
    required this.name,
    this.avatar,
    required this.birthDate,
    required this.gender,
    this.birthWeight,
    this.birthHeight,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'birthWeight': birthWeight,
      'birthHeight': birthHeight,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Baby.fromMap(Map<String, dynamic> map) {
    return Baby(
      id: map['id'],
      name: map['name'],
      avatar: map['avatar'],
      birthDate: DateTime.parse(map['birthDate']),
      gender: map['gender'],
      birthWeight: map['birthWeight']?.toDouble(),
      birthHeight: map['birthHeight']?.toDouble(),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Baby copyWith({
    String? id,
    String? name,
    String? avatar,
    DateTime? birthDate,
    String? gender,
    double? birthWeight,
    double? birthHeight,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Baby(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      birthWeight: birthWeight ?? this.birthWeight,
      birthHeight: birthHeight ?? this.birthHeight,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  int get ageInDays => DateTime.now().difference(birthDate).inDays;
  int get ageInMonths => (DateTime.now().year - birthDate.year) * 12 + DateTime.now().month - birthDate.month;
  String get ageString {
    final days = ageInDays;
    if (days < 30) {
      return '$days天';
    } else if (days < 365) {
      final months = days ~/ 30;
      return '$months个月${days % 30}天';
    } else {
      final years = days ~/ 365;
      final months = (days % 365) ~/ 30;
      return '$years岁$months个月';
    }
  }
}

class BabyList {
  final List<Baby> babies;

  BabyList({required this.babies});

  Baby? get currentBaby => babies.isNotEmpty ? babies.first : null;
  int get count => babies.length;
}