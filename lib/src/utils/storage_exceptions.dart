import '../../storage_sources_core.dart';

class _CustomException implements Exception {
  const _CustomException([this.message = '', this.source, this.stacktrace]);

  final String message;
  final dynamic source;
  final dynamic stacktrace;

  @override
  String toString() {
    return message;
  }
}

class StorageSourceException extends _CustomException {
  const StorageSourceException([
    super.message,
    super.source,
    super.stacktrace,
  ]);
}

class StorageException extends _CustomException {
  const StorageException([
    super.message,
    super.source,
    super.stacktrace,
  ]);
}

class OtherErrorStorageSourceResult<T> extends ErrorStorageSourceResult<T> {
  const OtherErrorStorageSourceResult(
    super.error, {
    super.stackTrace,
    super.handleErrorCallback,
  });
}
