import 'dart:async';
import 'package:storage_sources_core/src/complete_storage/storage_converter.dart';
import 'package:storage_sources_core/storage_sources_core.dart';

class StorageStreamedConverter<T, ProxyType,
        ProxyStorage extends StorageStreamed<ProxyType>>
    extends StorageConverter<T, ProxyType, ProxyStorage>
    implements StorageStreamedProxy<T, ProxyType, ProxyStorage> {
  const StorageStreamedConverter(
      {required super.parent,
      required super.converter,
      required this.streamConverter});

  final SR<T> Function(SR<ProxyType> data) streamConverter;

  @override
  Stream<SR<T>> dataStream() => parent.dataStream().map<SR<T>>(streamConverter);
}
