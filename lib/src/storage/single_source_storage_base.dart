import 'dart:async';

import '../../storage_sources_core.dart';

abstract class SingleSourceStorageBase<T, SourceType extends StorageSource<T>>
    implements Storage<T>, SingleSourceStorageSources<T> {
  const SingleSourceStorageBase();

  @override
  SourceType get source;

  @override
  FutureOr<SR<T>> fetchData() => source.fetchData();
}
