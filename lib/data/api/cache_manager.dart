// lib/data/api/cache_manager.dart
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();

  factory CacheManager() {
    return _instance;
  }

  CacheManager._internal();

  final Map<String, dynamic> _cache = {};

  // 初始化方法（如果有需要初始化的操作，可以放在这里）
  Future<void> init() async {
    // 如果有需要的初始化操作，可以在这里执行
  }

  dynamic get(String key) {
    return _cache[key];
  }

  void set(String key, dynamic value) {
    _cache[key] = value;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}
