import 'dart:async';

import 'package:meta/meta.dart';
import 'package:storage_sources_core/storage_sources_core.dart';

abstract interface class FileStorageSource<T>
    implements ModifiableDataStorageSource<T> {
  @protected
  Future<SR<T>> fileResultFromPath(String path);

  @protected
  FutureOr<bool> doFileExist(T file);

  @protected
  FutureOr<String> getFilePath(T file);

  @protected
  FutureOr<void> deleteFile(T file);
}

abstract interface class FileWithBytesStorageSource<T>
    implements FileStorageSource<T> {
  FutureOr<int> writeFileAndUpdate(String filePath, List<int> bytes);

  FutureOr<List<int>> fileBytes(T file);
}
