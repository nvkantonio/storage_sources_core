import '../../storage_sources_core.dart';

abstract class KeyedDataStorageSourceProxy<T, ProxyType,
        ProxySource extends KeyedDataStorageSource<ProxyType>>
    implements
        KeyedDataStorageSource<T>,
        StorageSourceProxy<T, ProxyType, ProxySource> {
  @override
  String get key => parent.key;
}
