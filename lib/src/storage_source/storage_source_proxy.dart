import '../../storage_sources_core.dart';

abstract interface class StorageSourceProxy<T, ProxyType,
    ProxySource extends StorageSource<ProxyType>> implements StorageSource<T> {
  ProxySource get parent;
}

abstract class ModifiableDataStorageSourceProxy<T, ProxyType,
        ProxySource extends ModifiableDataStorageSource<ProxyType>>
    implements
        ModifiableDataStorageSource<T>,
        StorageSourceProxy<T, ProxyType, ProxySource> {}

abstract class KeyedDataStorageSourceProxy<T, ProxyType,
        ProxySource extends KeyedDataStorageSource<ProxyType>>
    implements
        KeyedDataStorageSource<T>,
        StorageSourceProxy<T, ProxyType, ProxySource> {
  @override
  String get key => parent.key;
}
