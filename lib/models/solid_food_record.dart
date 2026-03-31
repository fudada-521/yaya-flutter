import 'dart:convert';
import 'base_record.dart';

/// 辅食记录数据模型
///
/// 独立记录宝宝辅食喂养情况，包括：
/// - 食物名称
/// - 份量
/// - 质地阶段
/// - 食材组成
class SolidFoodRecord extends BaseRecord {
  final DateTime mealTime; // 用餐时间
  final String? foodName; // 食物名称（如"米粉"、"南瓜泥"）
  final double? amount; // 份量 (g)
  final String texture; // 质地: puree(泥糊)/soft(软烂)/piece(小块)/solid(固体)
  final List<String>? ingredients; // 食材列表
  final String? notes; // 备注

  SolidFoodRecord({
    super.id,
    required super.babyId,
    required this.mealTime,
    this.foodName,
    this.amount,
    required this.texture,
    this.ingredients,
    this.notes,
    super.createdAt,
  });

  @override
  String get tableName => 'solid_food_records';

  /// 质地类型常量
  static const String texturePuree = 'puree'; // 泥糊
  static const String textureSoft = 'soft'; // 软烂
  static const String texturePiece = 'piece'; // 小块
  static const String textureSolid = 'solid'; // 固体

  /// 获取质地显示名称
  String get textureDisplayName {
    switch (texture) {
      case texturePuree:
        return '泥糊';
      case textureSoft:
        return '软烂';
      case texturePiece:
        return '小块';
      case textureSolid:
        return '固体';
      default:
        return texture;
    }
  }

  /// 质地类型列表（用于UI选择）
  static List<Map<String, String>> get textureOptions => [
        {'value': texturePuree, 'label': '泥糊', 'icon': '🫧'},
        {'value': textureSoft, 'label': '软烂', 'icon': '🥣'},
        {'value': texturePiece, 'label': '小块', 'icon': '🍖'},
        {'value': textureSolid, 'label': '固体', 'icon': '🍽️'},
      ];

  /// 常用食材列表（用于UI多选）
  static List<String> get commonIngredients => [
        '米粉',
        '南瓜',
        '胡萝卜',
        '土豆',
        '红薯',
        '苹果',
        '梨',
        '香蕉',
        '牛油果',
        '西兰花',
        '菠菜',
        '鸡肉',
        '猪肉',
        '鱼肉',
        '蛋黄',
        '豆腐',
      ];

  /// 获取份量显示
  String get amountDisplay {
    if (amount == null) return '';
    return '${amount!.toStringAsFixed(0)}g';
  }

  /// 获取食材显示
  String get ingredientsDisplay {
    if (ingredients == null || ingredients!.isEmpty) return '';
    return ingredients!.join('、');
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'mealTime': mealTime.toIso8601String(),
      'foodName': foodName,
      'amount': amount,
      'texture': texture,
      'ingredients': ingredients != null ? jsonEncode(ingredients) : null,
      'notes': notes,
    });
    return map;
  }

  factory SolidFoodRecord.fromMap(Map<String, dynamic> map) {
    List<String>? ingredientsList;
    if (map['ingredients'] != null) {
      final decoded = jsonDecode(map['ingredients']);
      if (decoded is List) {
        ingredientsList = decoded.cast<String>();
      }
    }

    return SolidFoodRecord(
      id: map['id'],
      babyId: map['babyId'],
      mealTime: DateTime.parse(map['mealTime']),
      foodName: map['foodName'],
      amount: map['amount']?.toDouble(),
      texture: map['texture'] ?? texturePuree,
      ingredients: ingredientsList,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  SolidFoodRecord copyWith({
    String? id,
    String? babyId,
    DateTime? createdAt,
    DateTime? mealTime,
    String? foodName,
    double? amount,
    String? texture,
    List<String>? ingredients,
    String? notes,
  }) {
    return SolidFoodRecord(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      createdAt: createdAt ?? this.createdAt,
      mealTime: mealTime ?? this.mealTime,
      foodName: foodName ?? this.foodName,
      amount: amount ?? this.amount,
      texture: texture ?? this.texture,
      ingredients: ingredients ?? this.ingredients,
      notes: notes ?? this.notes,
    );
  }
}
