import '../../storage_sources_core.dart';

abstract class ModifiableDataStorageSourceProxy<T, ProxyType,
        ProxySource extends ModifiableDataStorageSource<ProxyType>>
    implements
        ModifiableDataStorageSource<T>,
        StorageSourceProxy<T, ProxyType, ProxySource> {}
