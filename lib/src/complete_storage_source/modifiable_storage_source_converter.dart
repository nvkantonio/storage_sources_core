import 'dart:async';

import '../../storage_sources.dart';

class ModifiableStorageSourceConverter<T, ProxyType,
        ProxySource extends ModifiableDataStorageSource<ProxyType>>
    extends StorageSourceConverter<T, ProxyType, ProxySource>
    implements ModifiableDataStorageSourceProxy<T, ProxyType, ProxySource> {
  final ProxyType Function(T data) updateConverter;

  const ModifiableStorageSourceConverter({
    required super.parent,
    required super.converter,
    required this.updateConverter,
  });

  @override
  FutureOr update(T data) => parent.update(updateConverter(data));

  @override
  FutureOr delete() => parent.delete();
}
