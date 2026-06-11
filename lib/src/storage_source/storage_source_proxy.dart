import '../../storage_sources_core.dart';

abstract interface class StorageSourceProxy<T, ProxyType,
    ProxySource extends StorageSource<ProxyType>> implements StorageSource<T> {
  ProxySource get parent;
}
