import 'dart:async';
import '../../storage_sources_core.dart';

abstract interface class StorageSource<T> {
  FutureOr<SR<T>> fetchData();
}

/// [StorageSource] which data can be modified for later use
abstract interface class ModifiableDataStorageSource<T>
    implements StorageSource<T> {
  FutureOr update(T data);

  FutureOr delete();
}

/// [StorageSource] where access to data provided by key
abstract interface class KeyedDataStorageSource<T> implements StorageSource<T> {
  String get key;
}
