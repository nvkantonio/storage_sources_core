import 'package:test/test.dart';
import 'package:storage_sources_core/storage_sources_core.dart';

typedef SrOk<T> = OkStorageSourceResult<T>;
typedef SrUndef<T> = UndefinedStorageSourceResult<T>;
typedef SrError<T> = ErrorStorageSourceResult<T>;

void main() {
  group('A group of StorageSourceResult test', () {
    test(
      'Test ErrorStorageSourceResult',
      () async {
        final result1 = ErrorStorageSourceResult(
          'Forced exception',
          handleErrorCallback: (e, st) => 'New exception',
        );

        expect(result1.value, 'New exception');

        final result2 = ErrorStorageSourceResult(
          'Forced exception',
          handleErrorCallback: (e, st) => null,
        );

        // Because type is dynamic
        expect(result2.value, null);

        final result3 = ErrorStorageSourceResult<String>(
          'Forced exception',
          handleErrorCallback: (e, st) => null,
        );
        final result4 = ErrorStorageSourceResult<String>(
          'Forced exception',
          handleErrorCallback: (e, st) => () {}(),
        );

        expect(() => result3.value, throwsA(anything));
        expect(() => result4.value, throwsA(anything));
      },
    );
  });
}
