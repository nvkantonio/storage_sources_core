import 'dart:async';

import 'package:storage_sources_core/storage_sources_core.dart';

typedef FSR<T> = FutureOr<SR<T>>;

class StorageSourceConverter<T, ProxyType,
        ProxySource extends StorageSource<ProxyType>>
    implements StorageSourceProxy<T, ProxyType, ProxySource> {
  const StorageSourceConverter({required this.parent, required this.converter});

  @override
  final ProxySource parent;

  final FSR<T> Function(FSR<ProxyType> data) converter;

  @override
  FutureOr<SR<T>> fetchData() => converter(parent.fetchData());
}
