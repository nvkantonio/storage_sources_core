import 'package:storage_sources_core/callback_completer.dart';
import 'package:storage_sources_core/storage_sources_core.dart';
import 'package:test/test.dart';

typedef SrOk<T> = OkStorageSourceResult<T>;
typedef SrUndef<T> = UndefinedStorageSourceResult<T>;
typedef SrError<T> = ErrorStorageSourceResult<T>;

void main() {
  const testString1 = '1';
  const testString2 = '2';
  const testString3 = '3';
  const testString4 = '4';

  const testStringError = 'error';

  Future<String> futureTestString(String testString) => Future<String>.delayed(
        Duration(milliseconds: 50),
        () => testString,
      );

  Future<String> futureCauseError(String exceptionMessage) async {
    return Future<String>.delayed(
      Duration(milliseconds: 50),
      () => throw '$testStringError:$exceptionMessage',
    );
  }

  group('A group of CallbackCompleter tests without args (same as equal args)',
      () {
    test('Test CallbackCompleter runner. No args', () async {
      final callbackCompleter = CallbackCompleter<String>();

      expect(
          await callbackCompleter
              .run(() async => futureTestString(testString1)),
          testString1);

      expect(await callbackCompleter.run(() => futureTestString(testString2)),
          testString2);
    });

    test('Test CallbackCompleter multiple call. No args', () async {
      final callbackCompleter = CallbackCompleter<String>();

      final res1 = Future(
          () => callbackCompleter.run(() => futureTestString(testString1)));
      final res2 = Future(
          () => callbackCompleter.run(() => futureTestString(testString2)));
      final res3 = Future(
          () => callbackCompleter.run(() => futureTestString(testString3)));

      expect(await res1, testString1);

      final res4 = Future(
          () => callbackCompleter.run(() => futureTestString(testString4)));

      expect(await res2, testString1);
      expect(await res3, testString1);

      expect(await res4, testString4);
    });

    test('Test CallbackCompleter exceptions handle. No args', () async {
      final callbackCompleter = CallbackCompleter<String>();

      final res1 = Future(
              () => callbackCompleter.run(() => futureTestString(testString1)))
          .catchError((e, st) => '$e:$testString1');

      final res2 = Future(
              () => callbackCompleter.run(() => futureTestString(testString2)))
          .catchError((e, st) => '$e:$testString2');

      expect(await res1, testString1);
      expect(await res2, testString1);
    });

    test(
        'Test CallbackCompleter exceptions handle. No args. Must throw and .catchError must replace exception',
        () async {
      final callbackCompleter = CallbackCompleter<String>();

      final res1 = Future(
              () => callbackCompleter.run(() => futureCauseError(testString1)))
          .catchError((e, st) => e);

      final res2 = Future(
              () => callbackCompleter.run(() => futureCauseError(testString2)))
          .catchError((e, st) => e);

      expect(await res1, '$testStringError:$testString1');
      expect(await res2, '$testStringError:$testString1');
    });
  });

  group(
    'A group of test of CallbackCompleter with different equality arg',
    () {
      const testArg1 = 'arg1';
      const testArg2 = 'arg2';
      const testArg3 = 'arg3';
      const testArg4 = 'arg4';

      test('Test CallbackCompleter runner. Unequal args', () async {
        final callbackCompleter = CallbackCompleter<String>();

        expect(
            await callbackCompleter.run(
                () async => futureTestString(testString1), testArg1),
            testString1);

        expect(
            await callbackCompleter.run(
                () => futureTestString(testString2), testArg2),
            testString2);
      });

      test('Test CallbackCompleter multiple call. All args unequal', () async {
        final callbackCompleter = CallbackCompleter<String>();

        final res1 = Future(() => callbackCompleter.run(
            () => futureTestString(testString1), testArg1));
        final res2 = Future(() => callbackCompleter.run(
            () => futureTestString(testString2), testArg2));
        final res3 = Future(() => callbackCompleter.run(
            () => futureTestString(testString3), testArg3));

        expect(await res1, testString1);

        final res4 = Future(() => callbackCompleter.run(
            () => futureTestString(testString4), testArg4));

        expect(await res2, testString2);
        expect(await res3, testString3);

        expect(await res4, testString4);
      });

      test(
          'Test CallbackCompleter multiple call. Some args unequal. Queuing unequal args result',
          () async {
        final callbackCompleter = CallbackCompleter<String>();

        final res1 = Future(() => callbackCompleter.run(
            () => futureTestString(testString1), testArg1));
        final res2 = Future(() => callbackCompleter.run(
            () => futureTestString(testString2), testArg1));
        final res3 = Future(() => callbackCompleter.run(
            () => futureTestString(testString3), testArg2));

        expect(await res1, testString1);

        final res4 = Future(() => callbackCompleter.run(
            () => futureTestString(testString4), testArg2));

        expect(await res2, testString1);
        expect(await res3, testString3);

        expect(await res4, testString3);
      });

      test(
          'Test CallbackCompleter multiple call. Some args unequal. Queuing equal args result',
          () async {
        final callbackCompleter = CallbackCompleter<String>();

        final res1 = Future(() => callbackCompleter.run(
            () => futureTestString(testString1), testArg1));
        final res2 = Future(() => callbackCompleter.run(
            () => futureTestString(testString2), testArg1));
        final res3 = Future(() => callbackCompleter.run(
            () => futureTestString(testString3), testArg2));

        expect(await res3, testString3);

        final res4 = Future(() => callbackCompleter.run(
            () => futureTestString(testString4), testArg2));

        expect(await res1, testString1);
        expect(await res2, testString1);
        expect(await res3, testString3);

        expect(await res4, testString4);
      });

      test('Test CallbackCompleter exceptions handle. Unequal args', () async {
        final callbackCompleter = CallbackCompleter<String>();

        final res1 = Future(() => callbackCompleter.run(
                () => futureTestString(testString1), testArg1))
            .catchError((e, st) => '$e:$testString1');

        final res2 = Future(() => callbackCompleter.run(
                () => futureTestString(testString2), testArg2))
            .catchError((e, st) => '$e:$testString2');

        expect(await res1, testString1);
        expect(await res2, testString2);
      });

      test(
          'Test CallbackCompleter exceptions handle. Unequal args. Must throw and .catchError must replace exception',
          () async {
        final callbackCompleter = CallbackCompleter<String>();

        final res1 = Future(() => callbackCompleter.run(
                () => futureCauseError(testString1), testArg1))
            .catchError((e, st) => e);

        final res2 = Future(() => callbackCompleter.run(
                () => futureCauseError(testString2), testArg2))
            .catchError((e, st) => e);

        expect(await res1, '$testStringError:$testString1');
        expect(await res2, '$testStringError:$testString2');
      });
    },
  );
}
