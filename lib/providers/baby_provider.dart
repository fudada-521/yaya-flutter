import 'package:flutter/material.dart';
import '../models/baby.dart';
import '../database/database_helper.dart';

class BabyProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Baby> _babies = [];
  Baby? _currentBaby;
  bool _isLoading = true;
  String? _error;

  BabyProvider() {
    _initializeAndLoad();
  }

  List<Baby> get babies => _babies;
  Baby? get currentBaby => _currentBaby;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _initializeAndLoad() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 确保数据库已初始化
      await _databaseHelper.database;
      await _loadBabies();
    } catch (e) {
      _error = '初始化失败: $e';
      debugPrint('婴儿数据初始化失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadBabies() async {
    try {
      final babies = await _databaseHelper.getBabies();
      _babies = babies;
      if (_babies.isNotEmpty && _currentBaby == null) {
        _currentBaby = _babies.first;
      }
      _error = null;
    } catch (e) {
      _error = '加载失败: $e';
      debugPrint('加载婴儿数据失败: $e');
    }
    notifyListeners();
  }

  Future<bool> addBaby(Baby baby) async {
    try {
      await _databaseHelper.insertBaby(baby);
      await _loadBabies();
      return true;
    } catch (e) {
      debugPrint('添加婴儿失败: $e');
      _error = '添加婴儿失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBaby(Baby baby) async {
    try {
      await _databaseHelper.updateBaby(baby);
      await _loadBabies();
      return true;
    } catch (e) {
      debugPrint('更新婴儿信息失败: $e');
      _error = '更新婴儿信息失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBaby(String babyId) async {
    try {
      await _databaseHelper.deleteBaby(babyId);
      await _loadBabies();
      return true;
    } catch (e) {
      debugPrint('删除婴儿失败: $e');
      _error = '删除婴儿失败: $e';
      notifyListeners();
      return false;
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