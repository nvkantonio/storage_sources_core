import 'dart:async';
import 'package:storage_sources_core/storage_sources_core.dart';

@Deprecated('Use StorageStreamed')
typedef StorageStreamValue<T> = StorageStreamed<T>;

abstract interface class StorageStreamed<T> implements Storage<T> {
  Stream<SR<T>> dataStream();
}

abstract interface class StorageStreamedProxy<T, ProxyType,
        ProxySource extends StorageStreamed<ProxyType>>
    implements StorageStreamed<T>, StorageProxy<T, ProxyType, ProxySource> {
  ProxySource get parent;
}
