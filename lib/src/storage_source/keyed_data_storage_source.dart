import '../../storage_sources_core.dart';

/// [StorageSource] where access to data provided by key
abstract interface class KeyedDataStorageSource<T> implements StorageSource<T> {
  String get key;
}
