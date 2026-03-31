import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 食材服务
///
/// 管理食材列表的持久化存储。
/// 所有食材统一存储在 SharedPreferences 中，支持添加、删除、恢复默认。
class FoodIngredientService {
  static final FoodIngredientService _instance = FoodIngredientService._internal();
  factory FoodIngredientService() => _instance;
  FoodIngredientService._internal();

  static const String _ingredientsKey = 'food_ingredients';

  /// 精简后的默认食材列表
  static const List<String> defaultIngredients = [
    '米粉',
    '南瓜',
    '胡萝卜',
    '土豆',
    '苹果',
    '香蕉',
    '鸡肉',
    '蛋黄',
  ];

  /// 获取食材列表
  ///
  /// 如果用户从未设置过，返回默认食材列表。
  /// 否则返回用户自定义的列表。
  Future<List<String>> getIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_ingredientsKey);
    if (jsonString == null || jsonString.isEmpty) {
      // 首次使用，返回默认食材并自动保存
      await _saveIngredients(defaultIngredients);
      return defaultIngredients;
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<String>();
    } catch (e) {
      return defaultIngredients;
    }
  }

  /// 添加食材
  Future<bool> addIngredient(String ingredient) async {
    if (ingredient.trim().isEmpty) return false;

    final ingredients = await getIngredients();
    if (!ingredients.contains(ingredient.trim())) {
      ingredients.add(ingredient.trim());
      await _saveIngredients(ingredients);
    }
    return true;
  }

  /// 删除食材
  Future<bool> removeIngredient(String ingredient) async {
    final ingredients = await getIngredients();
    if (ingredients.remove(ingredient)) {
      await _saveIngredients(ingredients);
      return true;
    }
    return false;
  }

  /// 恢复默认食材
  Future<void> resetToDefault() async {
    await _saveIngredients(defaultIngredients);
  }

  /// 保存食材列表
  Future<void> _saveIngredients(List<String> ingredients) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(ingredients);
    await prefs.setString(_ingredientsKey, jsonString);
  }
}
