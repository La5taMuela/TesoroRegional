import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);
  Future<void> remove(String key);
  Future<void> clear();
}

class StorageServiceImpl implements StorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<String?> getString(String key) async {
    final p = await prefs;
    return p.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    final p = await prefs;
    await p.setString(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final p = await prefs;
    return p.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    final p = await prefs;
    await p.setBool(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    final p = await prefs;
    return p.getInt(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    final p = await prefs;
    await p.setInt(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final p = await prefs;
    await p.remove(key);
  }

  @override
  Future<void> clear() async {
    final p = await prefs;
    await p.clear();
  }
}
