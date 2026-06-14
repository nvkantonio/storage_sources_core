import 'package:meta/meta.dart';
import 'package:storage_sources_core/storage_sources.dart';

class MemoryCacheStorageSource<T>
    implements CacheStorageSource<T>, KeyedDataStorageSource<T> {
  MemoryCacheStorageSource({
    required this.key,
    Map<String, T>? existingCache,
  }) : memoryCache = existingCache ?? {};

  @override
  final String key;

  @protected
  @visibleForTesting
  final Map<String, T> memoryCache;

  bool get isCacheEmpty => memoryCache.isEmpty;

  SR<T> fetchData() {
    try {
      final result = memoryCache[key];

      if (result != null) {
        return OkStorageSourceResult<T>(result);
      } else {
        return UndefinedStorageSourceResult<T>();
      }
    } catch (e, st) {
      return ErrorStorageSourceResult<T>(e, stackTrace: st);
    }
  }

  void update(T newData) => memoryCache[key] = newData;

  void delete() => memoryCache.remove(key);
}
