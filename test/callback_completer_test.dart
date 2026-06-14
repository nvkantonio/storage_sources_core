import 'package:storage_sources_core/callback_completer.dart';
import 'package:storage_sources_core/storage_sources_core.dart';
import 'package:test/test.dart';

typedef SrOk<T> = OkStorageSourceResult<T>;
typedef SrUndef<T> = UndefinedStorageSourceResult<T>;
typedef SrError<T> = ErrorStorageSourceResult<T>;

void main() {
  const testString1 = '(data1)';
  const testString2 = '(data2)';
  const testString3 = '(data3)';
  const testString4 = '(data4)';

  const testStringError = '(error)';

  const testArg1 = '(arg1)';
  const testArg2 = '(arg2)';
  const testArg3 = '(arg3)';
  const testArg4 = '(arg4)';

  Future<String> futureTestString(String testString) => Future<String>.delayed(
        Duration(milliseconds: 50),
        () => testString,
      );

  Future<String> futureCauseErrorString(String exceptionMessage) async {
    return Future<String>.delayed(
      Duration(milliseconds: 50),
      () => throw '$testStringError:$exceptionMessage',
    );
  }

  group('A group of CallbackCompleter tests without args (same as equal args)',
      () {
    test('Test CallbackCompleter runner. No args', () async {
      final callbackCompleter = CallbackCompleter<String>();

      expect(callbackCompleter.isInProgress, false);

      expect(
        await callbackCompleter.run(
          () async => futureTestString(testString1),
        ),
        testString1,
      );

      expect(callbackCompleter.isInProgress, false);

      expect(
        await callbackCompleter.run(
          () => futureTestString(testString2),
        ),
        testString2,
      );

      expect(callbackCompleter.isInProgress, false);
    });

    test('Test CallbackCompleter simultaneous calls. No args', () async {
      final callbackCompleter = CallbackCompleter<String>();

      final res1 = Future(
        () => callbackCompleter.run(
          () => futureTestString(testString1),
        ),
      );
      final res2 = Future(
        () => callbackCompleter.run(
          () => futureTestString(testString2),
        ),
      );

      await Future.delayed(Duration(milliseconds: 1));
      expect(callbackCompleter.isInProgress, true);

      expect(await res1, testString1);
      expect(callbackCompleter.isInProgress, false);

      expect(await res2, testString1);
      expect(callbackCompleter.isInProgress, false);
    });

    test('Test CallbackCompleter mixing simultaneous calls. No args', () async {
      final callbackCompleter = CallbackCompleter<String>();

      final res1 = Future(
        () => callbackCompleter.run(
          () => futureTestString(testString1),
        ),
      );
      final res2 = Future(
        () => callbackCompleter.run(
          () => futureTestString(testString2),
        ),
      );
      final res3 = Future(
        () => callbackCompleter.run(
          () => futureTestString(testString3),
        ),
      );

      await Future.delayed(Duration(milliseconds: 1));
      expect(callbackCompleter.isInProgress, true);

      expect(await res1, testString1);

      expect(callbackCompleter.isInProgress, false);

      final res4 = Future(
        () => callbackCompleter.run(
          () => futureTestString(testString4),
        ),
      );

      await Future.delayed(Duration(milliseconds: 1));
      expect(callbackCompleter.isInProgress, true);

      expect(await res2, testString1);
      expect(callbackCompleter.isInProgress, true);

      expect(await res3, testString1);
      expect(callbackCompleter.isInProgress, true);

      expect(await res4, testString4);

      expect(callbackCompleter.isInProgress, false);
    });

    test('Test CallbackCompleter exceptions handle. No args', () async {
      final callbackCompleter = CallbackCompleter<String>();

      final res1 = Future(
        () => callbackCompleter.run(
          () => futureTestString(testString1),
        ),
      ).catchError((e, st) => '$e:$testString1');

      final res2 = Future(
        () => callbackCompleter.run(
          () => futureTestString(testString2),
        ),
      ).catchError((e, st) => '$e:$testString2');

      await Future.delayed(Duration(milliseconds: 1));
      expect(callbackCompleter.isInProgress, true);

      expect(await res1, testString1);
      expect(await res2, testString1);

      expect(callbackCompleter.isInProgress, false);
    });

    test(
        'Test CallbackCompleter exceptions handle. No args. Must throw and .catchError must replace exception',
        () async {
      final callbackCompleter = CallbackCompleter<String>();

      final res1 = Future(
        () => callbackCompleter.run(
          () => futureCauseErrorString(testString1),
        ),
      ).catchError((e, st) => e);

      final res2 = Future(
        () => callbackCompleter.run(
          () => futureCauseErrorString(testString2),
        ),
      ).catchError((e, st) => e);

      await Future.delayed(Duration(milliseconds: 1));
      expect(callbackCompleter.isInProgress, true);

      expect(await res1, '$testStringError:$testString1');
      expect(await res2, '$testStringError:$testString1');

      expect(callbackCompleter.isInProgress, false);
    });
  });

  group(
    'A group of test of CallbackCompleter with different equality arg',
    () {
      test('Test CallbackCompleter runner. Unequal args', () async {
        final callbackCompleter = CallbackCompleter<String>();

        expect(callbackCompleter.isInProgress, false);

        expect(
          await callbackCompleter.run(
            () async => futureTestString('$testString1$testArg1'),
            equalityArg: testArg1,
          ),
          '$testString1$testArg1',
        );

        expect(callbackCompleter.isInProgress, false);

        expect(
          await callbackCompleter.run(
            () => futureTestString('$testString1$testArg2'),
            equalityArg: testArg2,
          ),
          '$testString1$testArg2',
        );

        expect(callbackCompleter.isInProgress, false);
      });

      test('Test CallbackCompleter simultaneous calls. All args unequal',
          () async {
        final callbackCompleter = CallbackCompleter<String>();

        final res1 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString1$testArg1'),
            equalityArg: testArg1,
          ),
        );
        final res2 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString2$testArg2'),
            equalityArg: testArg2,
          ),
        );

        await Future.delayed(Duration(milliseconds: 1));
        expect(callbackCompleter.isInProgress, true);

        expect(await res1, '$testString1$testArg1');
        expect(callbackCompleter.isInProgress, true);

        expect(await res2, '$testString2$testArg2');
        expect(callbackCompleter.isInProgress, false);
      });

      test('Test CallbackCompleter mixing simultaneous calls. All args unequal',
          () async {
        final callbackCompleter = CallbackCompleter<String>();

        final res1 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString1$testArg1'),
            equalityArg: testArg1,
          ),
        );
        final res2 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString2$testArg2'),
            equalityArg: testArg2,
          ),
        );
        final res3 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString3$testArg3'),
            equalityArg: testArg3,
          ),
        );

        await Future.delayed(Duration(milliseconds: 1));
        expect(callbackCompleter.isInProgress, true);

        expect(await res1, '$testString1$testArg1');
        expect(callbackCompleter.isInProgress, true);

        final res4 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString4$testArg4'),
            equalityArg: testArg4,
          ),
        );

        expect(await res2, '$testString2$testArg2');
        expect(callbackCompleter.isInProgress, true);

        expect(await res3, '$testString3$testArg3');
        expect(callbackCompleter.isInProgress, true);

        expect(await res4, '$testString4$testArg4');

        expect(callbackCompleter.isInProgress, false);
      });

      test(
          'Test CallbackCompleter mixing simultaneous calls. Some args unequal. Queuing unequal args result',
          () async {
        final callbackCompleter = CallbackCompleter<String>();

        final res1 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString1$testArg1'),
            equalityArg: testArg1,
          ),
        );
        final res2 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString2$testArg1'),
            equalityArg: testArg1,
          ),
        );
        final res3 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString3$testArg2'),
            equalityArg: testArg2,
          ),
        );

        await Future.delayed(Duration(milliseconds: 1));
        expect(callbackCompleter.isInProgress, true);

        expect(await res1, '$testString1$testArg1');
        expect(callbackCompleter.isInProgress, true);

        final res4 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString4$testArg2'),
            equalityArg: testArg2,
          ),
        );

        expect(await res2, '$testString1$testArg1');
        expect(callbackCompleter.isInProgress, true);

        expect(await res3, '$testString3$testArg2');
        expect(callbackCompleter.isInProgress, false);

        expect(await res4, '$testString3$testArg2');
        expect(callbackCompleter.isInProgress, false);
      });

      test(
          'Test CallbackCompleter mixing simultaneous calls. Some args unequal. Queuing equal args result',
          () async {
        final callbackCompleter = CallbackCompleter<String>();

        final res1 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString1$testArg1'),
            equalityArg: testArg1,
          ),
        );
        final res2 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString2$testArg1'),
            equalityArg: testArg1,
          ),
        );
        final res3 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString3$testArg2'),
            equalityArg: testArg2,
          ),
        );

        await Future.delayed(Duration(milliseconds: 1));
        expect(callbackCompleter.isInProgress, true);

        expect(await res3, '$testString3$testArg2');
        expect(callbackCompleter.isInProgress, false);

        final res4 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString4$testArg2'),
            equalityArg: testArg2,
          ),
        );

        await Future.delayed(Duration(milliseconds: 1));
        expect(callbackCompleter.isInProgress, true);

        expect(await res1, '$testString1$testArg1');
        expect(callbackCompleter.isInProgress, true);

        expect(await res2, '$testString1$testArg1');
        expect(callbackCompleter.isInProgress, true);

        expect(await res4, '$testString4$testArg2');
        expect(callbackCompleter.isInProgress, false);
      });

      test('Test CallbackCompleter exceptions handle. Unequal args', () async {
        final callbackCompleter = CallbackCompleter<String>();

        final res1 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString1$testArg1'),
            equalityArg: testArg1,
          ),
        ).catchError((e) => '$e:$testString1');

        final res2 = Future(
          () => callbackCompleter.run(
            () => futureTestString('$testString2$testArg2'),
            equalityArg: testArg2,
          ),
        ).catchError((e) => '$e:$testString2');

        expect(await res1, '$testString1$testArg1');
        expect(await res2, '$testString2$testArg2');
      });

      test(
          'Test CallbackCompleter exceptions handle. Unequal args. Must throw and .catchError must replace exception',
          () async {
        final callbackCompleter = CallbackCompleter<String>();

        final res1 = Future(
          () => callbackCompleter.run(
            () => futureCauseErrorString('$testString1$testArg1'),
            equalityArg: testArg1,
          ),
        ).catchError((e) => e);

        final res2 = Future(
          () => callbackCompleter.run(
            () => futureCauseErrorString('$testString2$testArg2'),
            equalityArg: testArg2,
          ),
        ).catchError((e) => e);

        expect(await res1, '$testStringError:$testString1$testArg1');
        expect(await res2, '$testStringError:$testString2$testArg2');
      });
    },
  );

  group(
    'A group of test of CallbackCompleter with dynamic type',
    () {
      Future<R> futureTest<R>(R value) => Future<R>.delayed(
            Duration(milliseconds: 50),
            () => value,
          );

      Future<R> futureCauseError<R>(String exceptionMessage) async {
        return Future<R>.delayed(
          Duration(milliseconds: 50),
          () => throw '$testStringError:$exceptionMessage',
        );
      }

      test('Test CallbackCompleter runner with dynamic type. No args',
          () async {
        final callbackCompleter = CallbackCompleter();

        expect(
          await callbackCompleter.run(
            () async => futureTestString(testString1),
          ),
          testString1,
        );

        expect(
          await callbackCompleter.run<String>(
            () async => futureTestString(testString2),
          ),
          testString2,
        );

        expect(
          await callbackCompleter.run<int>(
            () => futureTest(3),
          ),
          3,
        );
      });

      test(
          'Test CallbackCompleter simultaneous calls with dynamic type. No args',
          () async {
        final callbackCompleter = CallbackCompleter();

        final res1 = Future(
          () => callbackCompleter.run<String>(
            () => futureTestString(testString1),
          ),
        );
        final res2 = Future(
          () => callbackCompleter.run(
            () => futureTestString(testString2),
          ),
        );
        final res3 = Future(
          () => callbackCompleter.run<String>(
            () => futureTestString(testString2),
          ),
        );

        await Future.delayed(Duration(milliseconds: 1));
        expect(callbackCompleter.isInProgress, true);

        expect(await res1, testString1);
        expect(callbackCompleter.isInProgress, false);

        expect(await res2, testString1);
        expect(await res3, testString1);
      });

      test(
          'Test CallbackCompleter simultaneous calls with dynamic type. No args. Set different types manually',
          () async {
        final callbackCompleter = CallbackCompleter();

        final res1 = Future(
          () => callbackCompleter.run<dynamic>(
            () => futureTest<dynamic>(testString1),
          ),
        );
        final res2 = Future(
          () => callbackCompleter.run<String>(
            () => futureTest<String>(testString2),
          ),
        );
        final res3 = Future(
          () => callbackCompleter.run<dynamic>(
            () => futureTest<String>(testString2),
          ),
        );

        await Future.delayed(Duration(milliseconds: 1));
        expect(callbackCompleter.isInProgress, true);

        expect(await res1, testString1);
        expect(callbackCompleter.isInProgress, true);

        // Dynamic type does not extends String type of latest callback.
        // This runs new process because types does not match
        expect(await res2, testString2);
        expect(callbackCompleter.isInProgress, false);

        // But String type extends dynamic type of latest callback.
        // This does not runs new process because types match.
        expect(await res3, testString2);
        expect(callbackCompleter.isInProgress, false);
      });

      test(
          'Test CallbackCompleter exceptions handle. No args. Set different types manually',
          () async {
        final callbackCompleter = CallbackCompleter();

        final res1 = Future(
          () => callbackCompleter.run<dynamic>(
            () => futureTest<dynamic>(testString1),
          ),
        ).catchError((e) => '$e:$testString1');

        final res2 = Future(
          () => callbackCompleter.run<String>(
            () => futureTest<String>(testString2),
          ),
        ).catchError((e) => '$e:$testString2');

        expect(await res1, testString1);
        expect(await res2, testString2);
      });

      test(
          'Test CallbackCompleter exceptions handle. No args. Set different types manually. Must throw and .catchError must replace exception',
          () async {
        final callbackCompleter = CallbackCompleter();

        final res1 = Future(
          () => callbackCompleter.run<dynamic>(
            () => futureCauseError<dynamic>(testString1),
          ),
        ).catchError((e) => e);

        final res2 = Future(
          () => callbackCompleter.run<String>(
            () => futureCauseError<String>(testString2),
          ),
        ).catchError((e) => e);

        expect(await res1, '$testStringError:$testString1');
        expect(await res2, '$testStringError:$testString2');
      });
    },
  );
}
