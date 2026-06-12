import 'dart:async';

import '../../storage_sources_core.dart';
import '../../misc.dart';

class CacheOrHeadmostStorageBehavior {
  const CacheOrHeadmostStorageBehavior({
    this.runTasksImmediately = true,
    this.runHeadmostSourceFirst = true,
    this.doRunSecondIfFirstOk = true,
    this.deleteCacheOnError = true,
    this.updateCacheIfNotEqual = true,
  });

  final bool runTasksImmediately;
  final bool runHeadmostSourceFirst;
  final bool doRunSecondIfFirstOk;
  final bool deleteCacheOnError;
  final bool updateCacheIfNotEqual;
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

    // Define order by behavior
    final invertOrder = !behavior.runHeadmostSourceFirst;

    bool doRunHeadmostSource() => !(invertOrder &&
        !behavior.doRunSecondIfFirstOk &&
        cacheSourceResponse is OkStorageSourceResult);

    bool doRunInverted() =>
        invertOrder &&
        !(!behavior.doRunSecondIfFirstOk &&
            headmostSourceResponse is OkStorageSourceResult);

    // Process runner
    if (!invertOrder) {
      yield cacheSourceResponse = await _handleSourceResponseFuture(
        cacheSourceResponseFuture,
      );
    }

    if (doRunHeadmostSource()) {
      yield headmostSourceResponse = await _handleSourceResponseFuture(
        headmostSourceResponseFuture,
      );
    }

    if (doRunInverted()) {
      yield cacheSourceResponse = await _handleSourceResponseFuture(
        cacheSourceResponseFuture,
      );
    }

    /// Post process tasks
    final doRunDelete = behavior.deleteCacheOnError &&
        cacheSourceResponse != null &&
        cacheSourceResponse.isError;

    final doTryUpdate = behavior.updateCacheIfNotEqual &&
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
            cacheSourceResponse.value != headmostValue;

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
