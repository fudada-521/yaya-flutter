import 'package:flutter/material.dart';
import '../models/baby.dart';
import '../database/database_helper.dart';

class BabyProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Baby> _babies = [];
  Baby? _currentBaby;

  BabyProvider() {
    _loadBabies();
  }

  List<Baby> get babies => _babies;
  Baby? get currentBaby => _currentBaby;

  Future<void> _loadBabies() async {
    try {
      final babies = await _databaseHelper.getBabies();
      _babies = babies;
      if (_babies.isNotEmpty && _currentBaby == null) {
        _currentBaby = _babies.first;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('加载婴儿数据失败: $e');
    }
  }

  Future<void> addBaby(Baby baby) async {
    try {
      await _databaseHelper.insertBaby(baby);
      await _loadBabies();
    } catch (e) {
      debugPrint('添加婴儿失败: $e');
    }
  }

  Future<void> updateBaby(Baby baby) async {
    try {
      await _databaseHelper.updateBaby(baby);
      await _loadBabies();
    } catch (e) {
      debugPrint('更新婴儿信息失败: $e');
    }
  }

  Future<void> deleteBaby(String babyId) async {
    try {
      await _databaseHelper.deleteBaby(babyId);
      await _loadBabies();
    } catch (e) {
      debugPrint('删除婴儿失败: $e');
    }
  }

  void setCurrentBaby(Baby baby) {
    _currentBaby = baby;
    notifyListeners();
  }

  void clearCurrentBaby() {
    _currentBaby = null;
    notifyListeners();
  }
}