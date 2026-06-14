import 'package:test/test.dart';
import 'package:storage_sources_core/storage_sources.dart';

typedef OkResponse<T> = OkStorageSourceResult<T>;
typedef UndefResponse<T> = UndefinedStorageSourceResult<T>;
typedef ErrorResponse<T> = ErrorStorageSourceResult<T>;

void main() {
  group('A group of CacheOrHeadmostStorage update tests', () {
    const testValue1 = 'testValue1';
    const testValue2 = 'testValue2';

    String callbackValue = testValue1;

    final cacheSource = MemoryCacheStorageSource<String?>(key: 'test-key');

    final storage = CacheOrHeadmostStorage<String?>(
      cacheSource: cacheSource,
      headmostSource: CallbackStorageSource(() => callbackValue),
      behavior: CacheOrHeadmostStorageBehavior(
        runTasksImmediately: true,
        runHeadmostSourceFirst: true,
        doRunSecondIfFirstOk: true,
        deleteCacheOnError: true,
        updateCacheIfNotEqual: true,
      ),
    );

    setUp(() async {
      callbackValue = testValue1;
    });

    tearDown(() async {
      cacheSource.memoryCache.clear();
    });

    test('Test cache value empty initially', () async {
      expect(await storage.dataStream().toList(),
          [UndefResponse<String?>(), OkResponse<String?>(testValue1)]);
    });

    test('Test cache value insert value', () async {
      expect(await storage.dataStream().toList(),
          [UndefResponse<String?>(), OkResponse<String?>(testValue1)]);

      expect(await storage.dataStream().toList(), [
        OkResponse<String?>(testValue1),
        OkResponse<String?>(testValue1),
      ]);
    });

    test('Test cache value replace value', () async {
      expect(await storage.dataStream().toList(),
          [UndefResponse<String?>(), OkResponse<String?>(testValue1)]);

      expect(await storage.dataStream().toList(), [
        OkResponse<String?>(testValue1),
        OkResponse<String?>(testValue1),
      ]);

      callbackValue = testValue2;

      expect(await storage.dataStream().toList(), [
        OkResponse<String?>(testValue1),
        OkResponse<String?>(testValue2),
      ]);

      expect(await storage.dataStream().toList(), [
        OkResponse<String?>(testValue2),
        OkResponse<String?>(testValue2),
      ]);
    });
  });

  group('A group of CacheOrHeadmostStorage update with delayed callback tests',
      () {
    const testValue1 = 'testValue1';
    const testValue2 = 'testValue2';

    String callbackValue = testValue1;

    final cacheSource = MemoryCacheStorageSource<String?>(key: 'test-key');

    final storage = CacheOrHeadmostStorage<String?>(
      cacheSource: cacheSource,
      headmostSource: CallbackStorageSource(
        () => Future.delayed(
          Duration(milliseconds: 20),
          () => callbackValue,
        ),
      ),
      behavior: CacheOrHeadmostStorageBehavior(
        runTasksImmediately: true,
        runHeadmostSourceFirst: true,
        doRunSecondIfFirstOk: true,
        deleteCacheOnError: true,
        updateCacheIfNotEqual: true,
      ),
    );

    setUp(() async {
      callbackValue = testValue1;
    });

    tearDown(() async {
      cacheSource.memoryCache.clear();
    });

    test('Test cache value insert value with delayed callback', () async {
      expect(await storage.dataStream().toList(),
          [UndefResponse<String?>(), OkResponse<String?>(testValue1)]);

      expect(await storage.dataStream().toList(), [
        OkResponse<String?>(testValue1),
        OkResponse<String?>(testValue1),
      ]);
    });

    test('Test cache value replace value with delayed callback', () async {
      expect(await storage.dataStream().toList(),
          [UndefResponse<String?>(), OkResponse<String?>(testValue1)]);

      expect(await storage.dataStream().toList(), [
        OkResponse<String?>(testValue1),
        OkResponse<String?>(testValue1),
      ]);

      callbackValue = testValue2;

      expect(await storage.dataStream().toList(), [
        OkResponse<String?>(testValue1),
        OkResponse<String?>(testValue2),
      ]);

      expect(await storage.dataStream().toList(), [
        OkResponse<String?>(testValue2),
        OkResponse<String?>(testValue2),
      ]);
    });
  });
}
