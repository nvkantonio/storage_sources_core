import '../../storage_sources_core.dart';

abstract interface class SingleSourceStorageSources<T>
    implements StorageSources {
  StorageSource<T> get source;
}
