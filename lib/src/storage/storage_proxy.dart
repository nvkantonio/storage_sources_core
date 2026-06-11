import '../../storage_sources_core.dart';

abstract interface class StorageProxy<T, ProxyType,
    ProxySource extends Storage<ProxyType>> implements Storage<T> {
  ProxySource get parent;
}
