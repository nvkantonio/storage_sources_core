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

  const testStringError = '(error)';

  const processLink1 = '(process1)';
  const processLink2 = '(process2)';

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

  group('A group of CallbackCompletersProcesses tests with multiple processes',
      () {
    test('Test CallbackCompletersProcesses runner', () async {
      final callbackCompletersProcesses = CallbackCompletersProcesses();

      expect(
          await callbackCompletersProcesses.run(
            () => futureTestString('$testString1$processLink1'),
            processLink: processLink1,
          ),
          '$testString1$processLink1');

      expect(callbackCompletersProcesses.completersHashMap[processLink1], null);

      expect(
          await callbackCompletersProcesses.run(
            () => futureTestString('$testString2$processLink2'),
            processLink: processLink2,
          ),
          '$testString2$processLink2');

      expect(callbackCompletersProcesses.completersHashMap[processLink2], null);

      expect(
          await callbackCompletersProcesses.run(
            () => futureTestString('$testString3$processLink1'),
            processLink: processLink1,
          ),
          '$testString3$processLink1');

      expect(callbackCompletersProcesses.completersHashMap[processLink1], null);
    });

    test('Test CallbackCompleter simultaneous calls', () async {
      final callbackCompletersProcesses = CallbackCompletersProcesses();

      expect(callbackCompletersProcesses.completersHashMap[processLink1], null);
      expect(callbackCompletersProcesses.completersHashMap[processLink2], null);

      final res1p1 = Future(
        () => callbackCompletersProcesses.run(
          () => futureTestString('$testString1$processLink1'),
          processLink: processLink1,
        ),
      );

      final res2p2 = Future(
        () => callbackCompletersProcesses.run(
          () => futureTestString('$testString2$processLink2'),
          processLink: processLink2,
        ),
      );

      final res3p1 = Future(
        () => callbackCompletersProcesses.run(
          () => futureTestString('$testString3$processLink1'),
          processLink: processLink1,
        ),
      );

      await Future.delayed(Duration(milliseconds: 1));
      expect(
        callbackCompletersProcesses
            .completerOfProcess(processLink1)
            ?.isInProgress,
        true,
      );
      expect(
        callbackCompletersProcesses
            .completerOfProcess(processLink2)
            ?.isInProgress,
        true,
      );

      expect(await res1p1, '$testString1$processLink1');

      expect(callbackCompletersProcesses.completersHashMap[processLink1], null);

      expect(await res2p2, '$testString2$processLink2');

      expect(callbackCompletersProcesses.completersHashMap[processLink2], null);

      expect(await res3p1, '$testString1$processLink1');

      expect(callbackCompletersProcesses.completersHashMap[processLink1], null);
    });

    test('Test CallbackCompleter mixing simultaneous calls', () async {
      final callbackCompletersProcesses = CallbackCompletersProcesses();

      final res1p1 = Future(
        () => callbackCompletersProcesses.run(
          () => futureTestString('$testString1$processLink1'),
          processLink: processLink1,
        ),
      );

      final res2p2 = Future(
        () => callbackCompletersProcesses.run(
          () => futureTestString('$testString2$processLink2'),
          processLink: processLink2,
        ),
      );

      final res3p1 = Future(
        () => callbackCompletersProcesses.run(
          () => futureTestString('$testString3$processLink1'),
          processLink: processLink1,
        ),
      );

      await Future.delayed(Duration(milliseconds: 1));
      expect(
        callbackCompletersProcesses
            .completerOfProcess(processLink1)
            ?.isInProgress,
        true,
      );
      expect(
        callbackCompletersProcesses
            .completerOfProcess(processLink2)
            ?.isInProgress,
        true,
      );

      expect(await res1p1, '$testString1$processLink1');
      expect(
        callbackCompletersProcesses.completerOfProcess(processLink1),
        null,
      );
      expect(
        callbackCompletersProcesses
            .completerOfProcess(processLink2)
            ?.isInProgress,
        true,
      );

      expect(await res2p2, '$testString2$processLink2');
      expect(
        callbackCompletersProcesses.completerOfProcess(processLink2),
        null,
      );

      expect(await res3p1, '$testString1$processLink1');

      expect(
        callbackCompletersProcesses.completersHashMap[processLink1],
        null,
      );
      expect(
        callbackCompletersProcesses.completerOfProcess(processLink2),
        null,
      );
    });

    test(
        'Test CallbackCompletersProcesses exceptions handle mixing simultaneous calls. Must throw and .catchError must replace exception',
        () async {
      final callbackCompletersProcesses = CallbackCompletersProcesses();

      final res1p1 = Future(
        () => callbackCompletersProcesses.run(
          () => futureCauseErrorString('$testString1$processLink1'),
          processLink: processLink1,
        ),
      ).catchError((e, st) => e);

      final res2p2 = Future(
        () => callbackCompletersProcesses.run(
          () => futureCauseErrorString('$testString2$processLink2'),
          processLink: processLink2,
        ),
      ).catchError((e, st) => e);

      final res3p1 = Future(
        () => callbackCompletersProcesses.run(
          () => futureCauseErrorString('$testString3$processLink1'),
          processLink: processLink1,
        ),
      ).catchError((e, st) => e);

      await Future.delayed(Duration(milliseconds: 1));
      expect(
        callbackCompletersProcesses
            .completerOfProcess(processLink1)
            ?.isInProgress,
        true,
      );
      expect(
        callbackCompletersProcesses
            .completerOfProcess(processLink2)
            ?.isInProgress,
        true,
      );

      expect(await res1p1, '$testStringError:$testString1$processLink1');
      expect(
        callbackCompletersProcesses.completerOfProcess(processLink1),
        null,
      );
      expect(
        callbackCompletersProcesses
            .completerOfProcess(processLink2)
            ?.isInProgress,
        true,
      );

      expect(await res2p2, '$testStringError:$testString2$processLink2');
      expect(
        callbackCompletersProcesses.completerOfProcess(processLink2),
        null,
      );
      expect(await res3p1, '$testStringError:$testString1$processLink1');

      expect(
        callbackCompletersProcesses.completersHashMap[processLink1],
        null,
      );
      expect(
        callbackCompletersProcesses.completerOfProcess(processLink2),
        null,
      );
    });
  });
}
