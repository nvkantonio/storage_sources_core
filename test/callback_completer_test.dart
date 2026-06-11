import 'package:storage_sources_core/callback_completer.dart';
import 'package:storage_sources_core/storage_sources_core.dart';
import 'package:test/test.dart';

typedef SrOk<T> = OkStorageSourceResult<T>;
typedef SrUndef<T> = UndefinedStorageSourceResult<T>;
typedef SrError<T> = ErrorStorageSourceResult<T>;

void main() {
  group('A group of CallbackCompleter test', () {
    const testString = 'yes-yes-yes';
    const testString2 = '2';
    const testString3 = '3';
    const testString4 = '4';
    const testStringError = 'error';

    Future<String> futureTestString(String testString) =>
        Future<String>.delayed(
          Duration(milliseconds: 50),
          () => testString,
        );

    Future<String> futureCauseError(String exceptionMessage) async {
      return Future<String>.delayed(
        Duration(milliseconds: 50),
        () => throw '$testStringError:$exceptionMessage',
      );
    }

    test('Test CallbackCompleter runner', () async {
      final callbackCompleter = CallbackCompleter<String>();

      expect(
          await callbackCompleter.run(() async => futureTestString(testString)),
          testString);

      expect(await callbackCompleter.run(() => futureTestString(testString)),
          testString);
    });

    test('Test CallbackCompleter multiple call must result in save response',
        () async {
      final callbackCompleter = CallbackCompleter<String>();

      final res1 = Future(
          () => callbackCompleter.run(() => futureTestString(testString)));
      final res2 = Future(
          () => callbackCompleter.run(() => futureTestString(testString2)));
      final res3 = Future(
          () => callbackCompleter.run(() => futureTestString(testString3)));

      expect(await res1, testString);

      final res4 = Future(
          () => callbackCompleter.run(() => futureTestString(testString4)));

      expect(await res2, testString);
      expect(await res3, testString);

      expect(await res4, testString4);
    });

    test('Test CallbackCompleter', () async {
      final callbackCompleter = CallbackCompleter<String>();

      final res1 = Future(
              () => callbackCompleter.run(() => futureTestString(testString)))
          .catchError((e, st) => '$e:$testString');

      final res2 = Future(
              () => callbackCompleter.run(() => futureTestString(testString2)))
          .catchError((e, st) => '$e:$testString2');

      expect(await res1, testString);
      expect(await res2, testString);
    });

    test('Test CallbackCompleter', () async {
      final callbackCompleter = CallbackCompleter<String>();

      final res3 = Future(
              () => callbackCompleter.run(() => futureCauseError(testString)))
          .catchError((e, st) => e);

      final res4 = Future(
              () => callbackCompleter.run(() => futureCauseError(testString2)))
          .catchError((e, st) => e);

      expect(await res3, '$testStringError:$testString');
      expect(await res4, '$testStringError:$testString');
    });
  });
}
