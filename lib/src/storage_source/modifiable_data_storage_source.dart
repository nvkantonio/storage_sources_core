import 'dart:async';

import '../../storage_sources_core.dart';

/// [StorageSource] which data can be modified for later use
abstract interface class ModifiableDataStorageSource<T>
    implements StorageSource<T> {
  FutureOr update(T data);

  FutureOr delete();
}
