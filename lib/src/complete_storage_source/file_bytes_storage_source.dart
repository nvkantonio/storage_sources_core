import 'dart:async';

import '../../storage_sources.dart';

class FileBytesStorageSource<S>
    implements
        ModifiableDataStorageSourceProxy<List<int>, S,
            FileWithBytesStorageSource<S>> {
  const FileBytesStorageSource(this.parent, {required this.createNewFilePath});

  @override
  final FileWithBytesStorageSource<S> parent;

  final String createNewFilePath;

  @override
  FutureOr<SR<List<int>>> fetchData() async {
    try {
      final SR<S> fileResponse = await parent.fetchData();

      if (!fileResponse.isOk) {
        return fileResponse.convert();
      }

      final fileBytes = await parent.fileBytes(fileResponse.value);

      return OkStorageSourceResult(fileBytes);
    } catch (e, st) {
      return ErrorStorageSourceResult(e, stackTrace: st);
    }
  }

  @override
  FutureOr update(List<int> data) {
    return parent.writeFileAndUpdate(createNewFilePath, data);
  }

  @override
  FutureOr delete() => parent.delete();
}
