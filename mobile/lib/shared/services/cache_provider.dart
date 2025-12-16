import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cache_service.dart';

/// Cache service provider (singleton)
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

/// Initialize cache on app startup
final cacheInitProvider = FutureProvider<void>((ref) async {
  final cache = ref.watch(cacheServiceProvider);
  await cache.init();
});

/// Clear cache (call on sign out)
final clearCacheProvider = Provider<Future<void> Function()>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return cache.clearCache;
});
