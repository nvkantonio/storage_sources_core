import 'package:test/test.dart';
import 'package:storage_sources_core/storage_sources.dart';

typedef OkResponse<T> = OkStorageSourceResult<T>;
typedef UndefResponse<T> = UndefinedStorageSourceResult<T>;
typedef ErrorResponse<T> = ErrorStorageSourceResult<T>;

void main() {
  group('A group of MemoryCacheStorageSource tests', () {
    test('Test MemoryCacheStorageSource fetch, update and delete', () {
      const testValue = 'yes-yes-yes';

      final source = MemoryCacheStorageSource<String>(
        key: 'test-key',
      );

      expect(source.isCacheEmpty, true);

      expect(source.fetchData(), UndefResponse<String>());

      source.update(testValue);

      expect(source.isCacheEmpty, false);

      expect(source.fetchData(), OkResponse<String>(testValue));

      source.delete();

      expect(source.fetchData(), UndefResponse<String>());
    });
  });
}
