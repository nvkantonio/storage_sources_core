import 'dart:async';

import '../../storage_sources_core.dart';

/// [StorageSource] to fetch data from callback
class CallbackStorageSource<T> implements StorageSource<T> {
  const CallbackStorageSource(this.fetchDataCallback);

  final FutureOr<T> Function() fetchDataCallback;

  @override
  FutureOr<SR<T>> fetchData() {
    return StorageSourceResult.checkAsync(fetchDataCallback);
  }
}
