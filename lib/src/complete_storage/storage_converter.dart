import 'dart:async';

import 'package:storage_sources_core/storage_sources_core.dart';

typedef FSR<T> = FutureOr<SR<T>>;

class StorageConverter<T, ProxyType, ProxyStorage extends Storage<ProxyType>>
    implements StorageProxy<T, ProxyType, ProxyStorage> {
  const StorageConverter({required this.parent, required this.converter});

  @override
  final ProxyStorage parent;

  final FSR<T> Function(FSR<ProxyType> data) converter;

  @override
  FutureOr<SR<T>> fetchData() => converter(parent.fetchData());
}
