import 'dart:async';

import '../../storage_sources_core.dart';
import '../../misc.dart';

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

  final bool yieldUndefinedIfHaveOkResponse;
  final bool yieldSecondIfFirstEqual;
}

abstract interface class CacheOrHeadmostStorageSources<T>
    implements StorageSources {
  StorageSource<T> get headmostSource;
  ModifiableDataStorageSource<T> get cacheSource;
}

abstract class _CacheOrHeadmostStorage<T>
    with StorageStreamedGetDataLatestMixin<T>
    implements CacheOrHeadmostStorageSources<T> {
  const _CacheOrHeadmostStorage();
}

class CacheOrHeadmostStorage<T> extends _CacheOrHeadmostStorage<T> {
  const CacheOrHeadmostStorage({
    required this.cacheSource,
    required this.headmostSource,
    this.behavior = const CacheOrHeadmostStorageBehavior(),
  });

  final CacheOrHeadmostStorageBehavior behavior;

  @override
  final ModifiableDataStorageSource<T> cacheSource;

  @override
  final StorageSource<T> headmostSource;

  @override
  Stream<SR<T>> dataStream() async* {
    final Future<SR<T>> cacheSourceResponseFuture;
    final Future<SR<T>> headmostSourceResponseFuture;

    SR<T>? cacheSourceResponse;
    SR<T>? headmostSourceResponse;

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
    final inverted = !behavior.runCacheSourceFirst;
    final checkRunSecond = !behavior.doRunSecondIfFirstOk;
    final checkEqual = !behavior.yieldSecondIfFirstEqual;
    final checkUndef = !behavior.yieldUndefinedIfHaveOkResponse;

    // Process runner
    final bool yieldFirst;
    final bool yieldSecond;

    if (!inverted) {
      cacheSourceResponse = await handleCacheSource();

      yieldFirst = cacheSourceResponse is ErrorStorageSourceResult ||
          !(checkUndef && cacheSourceResponse is UndefinedStorageSourceResult);

      if (yieldFirst) {
        yield cacheSourceResponse;
      }

      final runSecond =
          checkRunSecond && cacheSourceResponse is OkStorageSourceResult;

      if (runSecond) {
        headmostSourceResponse = await handleHeadmostSource();

        yieldSecond = headmostSourceResponse is ErrorStorageSourceResult ||
            !(checkUndef &&
                    headmostSourceResponse is UndefinedStorageSourceResult) &&
                !(checkEqual &&
                    cacheSourceResponse.value == headmostSourceResponse.value);

        if (yieldSecond) {
          yield headmostSourceResponse;
        }
      } else {
        yieldSecond = false;
      }
    } else {
      headmostSourceResponse = await handleHeadmostSource();

      yieldFirst = headmostSourceResponse is ErrorStorageSourceResult ||
          !(checkUndef &&
              headmostSourceResponse is UndefinedStorageSourceResult);

      if (yieldFirst) {
        yield headmostSourceResponse;
      }

      final runSecond =
          checkRunSecond && headmostSourceResponse is OkStorageSourceResult;

      if (runSecond) {
        cacheSourceResponse = await handleCacheSource();

        yieldSecond = cacheSourceResponse is ErrorStorageSourceResult ||
            !(checkUndef &&
                    cacheSourceResponse is UndefinedStorageSourceResult) &&
                !(checkEqual && cacheSourceResponse == cacheSourceResponse);

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
        await cacheSource.delete();
      } catch (e, st) {
        yield OtherErrorStorageSourceResult(e, stackTrace: st);
        return;
      }
    }

    if (doTryUpdate) {
      try {
        final headmostValue = headmostSourceResponse.value;

        final doUpdate = !cacheSourceResponse.isOk ||
            (behavior.updateCacheIfNotEqual &&
                cacheSourceResponse.value != headmostValue);

        if (doUpdate) {
          await cacheSource.update(headmostValue);
        }
      } catch (e, st) {
        yield OtherErrorStorageSourceResult(e, stackTrace: st);
        return;
      }
    }
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
