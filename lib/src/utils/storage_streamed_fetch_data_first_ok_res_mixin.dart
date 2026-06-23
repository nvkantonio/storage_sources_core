import 'dart:async';
import 'dart:developer' as dev;
import 'package:storage_sources_core/storage_sources_core.dart';

typedef ActionOnOk<T> = Function(OkStorageSourceResult<T> result);
typedef ActionOnError<T> = Function(ErrorStorageSourceResult<T> result);
typedef ActionOnUndefined<T> = Function(UndefinedStorageSourceResult<T> result);

mixin StorageStreamedFetchDataFirstOkResMixin<T> implements StorageStreamed<T> {
  @override
  FutureOr<SR<T>> fetchData([
    ActionOnOk<T>? actionOnOk,
    ActionOnError<T>? actionOnError,
    ActionOnUndefined<T>? actionOnUndefined,
    Function(Object e, StackTrace st)? onUnhandledError,
  ]) async {
    final completer = Completer<SR<T>>.sync();

    ErrorStorageSourceResult<T>? latestError;

    final sub = dataStream().listen(
      (event) {
        switch (event) {
          case OkStorageSourceResult<T> res:
            if (!completer.isCompleted) {
              completer.complete(res);
            }

            actionOnOk?.call(res);

          case ErrorStorageSourceResult<T> res:
            latestError = res;
            actionOnError?.call(res);
          case UndefinedStorageSourceResult<T> res:
            actionOnUndefined?.call(res);
        }
      },
    );

    sub.onError(
      (Object e, StackTrace st) {
        if (!completer.isCompleted) {
          completer.completeError(e, st);
        }

        if (onUnhandledError != null) {
          onUnhandledError(e, st);
        } else {
          dev.log('Unhandled fetchData error: $e', error: e, stackTrace: st);
        }
      },
    );

    sub.onDone(
      () {
        if (!completer.isCompleted) {
          if (latestError != null) {
            completer.complete(latestError);
          } else {
            completer.complete(const UndefinedStorageSourceResult());
          }
        }
      },
    );

    return completer.future;
  }
}
