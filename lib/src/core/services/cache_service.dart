// lib/core/services/cache_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  final SharedPreferences _sharedPreferences;

  CacheService({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  Future<bool> saveData({required String key, required String value}) {
    return _sharedPreferences.setString(key, value);
  }

  String? getData({required String key}) {
    return _sharedPreferences.getString(key);
  }

  Future<bool> removeData({required String key}) {
    return _sharedPreferences.remove(key);
  }

  Future<bool> clearAllData() {
    return _sharedPreferences.clear();
  }
}
