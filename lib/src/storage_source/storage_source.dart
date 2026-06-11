import 'dart:async';
import '../../storage_sources_core.dart';

abstract interface class StorageSource<T> {
  FutureOr<SR<T>> fetchData();
}
