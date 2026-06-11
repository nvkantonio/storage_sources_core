import 'dart:async';
import 'package:storage_sources_core/storage_sources_core.dart';

@Deprecated('Use StorageStreamed')
typedef StorageStreamValue<T> = StorageStreamed<T>;

abstract interface class StorageStreamed<T> implements Storage<T> {
  Stream<SR<T>> dataStream();
}
