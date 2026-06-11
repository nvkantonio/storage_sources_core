import '../../storage_sources_core.dart';

abstract class SingleSourceStorage<T, SourceType extends StorageSource<T>>
    extends SingleSourceStorageBase {
  const SingleSourceStorage(this.source);

  @override
  final SourceType source;
}
