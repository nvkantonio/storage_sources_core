import 'dart:async';

import '../../storage_sources_core.dart';
import '../../misc.dart';

typedef EqualityCheckCallback<T> = bool Function(T cache, T headmost);

typedef UpdateActionCallback<T> = FutureOr Function(
  StorageSourceResult<T> cacheSourceResult,
  OkStorageSourceResult<T> headmostSourceResult,
);

typedef DeleteActionCallback<T> = FutureOr Function(
  StorageSourceResult<T> cacheSourceResult,
  StorageSourceResult<T>? headmostSourceResult,
);

class CacheOrHeadmostStorageBehavior {
  const CacheOrHeadmostStorageBehavior({
    this.runCacheSourceFirst = true,
    this.doRunSecondIfFirstOk = true,
    this.runTasksImmediately = true,
    this.doTryUpdateCache = true,
    this.updateCacheIfNotEqual = true,
    this.deleteCacheOnError = true,
    this.yieldSecondIfFirstEqual = true,
    this.yieldUndefinedIfHaveOkResponse = true,
  });

  final bool runCacheSourceFirst;

  final bool doRunSecondIfFirstOk;

  final bool runTasksImmediately;

  final bool doTryUpdateCache;
  final bool updateCacheIfNotEqual;
  final bool deleteCacheOnError;

  /// When false yield undefined once if only no ok result or errors occurred
  final bool yieldUndefinedIfHaveOkResponse;

  /// When false wont yield second source result if only both are ok and equals
  final bool yieldSecondIfFirstEqual;
}

abstract interface class CacheOrHeadmostStorageSources<T>
    implements StorageSources {
  StorageSource<T> get headmostSource;
  ModifiableDataStorageSource<T> get cacheSource;
}

abstract class _CacheOrHeadmostStorage<T>
    with StorageStreamedFetchDataFirstOkResMixin<T>
    implements CacheOrHeadmostStorageSources<T> {
  const _CacheOrHeadmostStorage();
}

class CacheOrHeadmostStorage<T> extends _CacheOrHeadmostStorage<T> {
  const CacheOrHeadmostStorage({
    required this.cacheSource,
    required this.headmostSource,
    this.behavior = const CacheOrHeadmostStorageBehavior(),
    this.equalityCheck,
    this.updateAction,
    this.deleteAction,
  });

  final CacheOrHeadmostStorageBehavior behavior;

  @override
  final ModifiableDataStorageSource<T> cacheSource;

  @override
  final StorageSource<T> headmostSource;

  final EqualityCheckCallback<T>? equalityCheck;
  final UpdateActionCallback<T>? updateAction;
  final DeleteActionCallback<T>? deleteAction;

  @override
  Stream<SR<T>> dataStream() async* {
    final Future<SR<T>> cacheSourceResponseFuture;
    final Future<SR<T>> headmostSourceResponseFuture;

    SR<T>? cacheSourceResponse;
    SR<T>? headmostSourceResponse;

    bool equalityCheck() {
      if (cacheSourceResponse?.isOk != true ||
          headmostSourceResponse?.isOk != true) {
        return false;
      }

      final cache = cacheSourceResponse!.value;
      final headmost = headmostSourceResponse!.value;

      if (this.equalityCheck != null) {
        return this.equalityCheck!.call(cache, headmost);
      } else {
        return cache == headmost;
      }
    }

    // Processes initialization
    if (behavior.runTasksImmediately) {
      cacheSourceResponseFuture = Future(cacheSource.fetchData);
      headmostSourceResponseFuture = Future(headmostSource.fetchData);
    } else {
      cacheSourceResponseFuture = cacheSource.fetchData().future;
      headmostSourceResponseFuture = headmostSource.fetchData().future;
    }

    Future<SR<T>> handleCacheSource() =>
        _handleSourceResponseFuture(cacheSourceResponseFuture);

    Future<SR<T>> handleHeadmostSource() =>
        _handleSourceResponseFuture(headmostSourceResponseFuture);

    // Define order by behavior
    final runCacheSourceFirst = !behavior.runCacheSourceFirst;
    final doRunSecondIfFirstOk = !behavior.doRunSecondIfFirstOk;
    final yieldSecondIfFirstEqual = !behavior.yieldSecondIfFirstEqual;
    final yieldUndefined = !behavior.yieldUndefinedIfHaveOkResponse;

    bool checkUndef(StorageSourceResult<T> res) =>
        yieldUndefined || !res.isUndefined;

    bool checkUndefAndEquality(StorageSourceResult<T> res) =>
        checkUndef(res) && (yieldSecondIfFirstEqual || !equalityCheck());

    // Process runner
    final bool yieldFirst;
    final bool yieldSecond;

    if (runCacheSourceFirst) {
      cacheSourceResponse = await handleCacheSource();

      yieldFirst =
          cacheSourceResponse.isError || checkUndef(cacheSourceResponse);

      if (yieldFirst) {
        yield cacheSourceResponse;
      }

      final runSecond = doRunSecondIfFirstOk || cacheSourceResponse.isOk;

      if (runSecond) {
        headmostSourceResponse = await handleHeadmostSource();

        yieldSecond = headmostSourceResponse.isError ||
            checkUndefAndEquality(headmostSourceResponse);

        if (yieldSecond) {
          yield headmostSourceResponse;
        }
      } else {
        yieldSecond = false;
      }
    } else {
      headmostSourceResponse = await handleHeadmostSource();

      yieldFirst =
          headmostSourceResponse.isError || checkUndef(headmostSourceResponse);

      if (yieldFirst) {
        yield headmostSourceResponse;
      }

      final runSecond = doRunSecondIfFirstOk || headmostSourceResponse.isOk;

      if (runSecond) {
        cacheSourceResponse = await handleCacheSource();

        yieldSecond = cacheSourceResponse.isError ||
            checkUndefAndEquality(cacheSourceResponse);

        if (yieldSecond) {
          yield cacheSourceResponse;
        }
      } else {
        yieldSecond = false;
      }
    }

    if (!(yieldFirst || yieldSecond)) {
      yield UndefinedStorageSourceResult<T>();
    }

    /// Post process tasks
    final doRunDelete = behavior.deleteCacheOnError &&
        cacheSourceResponse != null &&
        cacheSourceResponse.isError;

    final doTryUpdate = behavior.doTryUpdateCache &&
        cacheSourceResponse != null &&
        headmostSourceResponse != null &&
        headmostSourceResponse.isOk;

    if (doRunDelete) {
      try {
        await deleteCache(cacheSourceResponse, headmostSourceResponse);
      } catch (e, st) {
        yield OtherErrorStorageSourceResult(e, stackTrace: st);
        return;
      }
    }

    if (doTryUpdate) {
      try {
        final doUpdate = !cacheSourceResponse.isOk ||
            (behavior.updateCacheIfNotEqual && !equalityCheck());

        if (doUpdate) {
          await updateCache(cacheSourceResponse,
              headmostSourceResponse as OkStorageSourceResult<T>);
        }
      } catch (e, st) {
        yield OtherErrorStorageSourceResult(e, stackTrace: st);
        return;
      }
    }
  }

  FutureOr<void> updateCache(StorageSourceResult<T> cacheSourceResult,
      OkStorageSourceResult<T> headmostSourceResult) {
    if (updateAction != null) {
      return updateAction!.call(cacheSourceResult, headmostSourceResult);
    }

    return cacheSource.update(headmostSourceResult.value);
  }

  FutureOr<void> deleteCache(StorageSourceResult<T> cacheSourceResult,
      StorageSourceResult<T>? headmostSourceResult) {
    if (updateAction != null) {
      return deleteAction!.call(cacheSourceResult, headmostSourceResult);
    }

    return cacheSource.delete();
  }

  Future<SR<T>> _handleSourceResponseFuture(
    Future<SR<T>> sourceResponseFuture,
  ) async {
    try {
      return await sourceResponseFuture;
    } catch (e, st) {
      return ErrorStorageSourceResult(e, stackTrace: st);
    }
  }
}
