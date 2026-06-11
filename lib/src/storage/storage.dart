import 'dart:async';
import '../../storage_sources_core.dart';

abstract interface class Storage<T> {
  FutureOr<SR<T>> fetchData();
}

abstract interface class StorageStreamValue<T> implements Storage<T> {
  Stream<SR<T>> dataStream();
}
