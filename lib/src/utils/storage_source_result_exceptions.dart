import '../../misc.dart';

class StorageSourceResultUndefinedValueException
    extends StorageSourceException {
  const StorageSourceResultUndefinedValueException([
    super.message,
    super.source,
    super.stacktrace,
  ]);
}

class StorageSourceResultNotAnErrorException extends StorageSourceException {
  const StorageSourceResultNotAnErrorException([
    super.message,
    super.source,
    super.stacktrace,
  ]);
}

class StorageSourceResultInvalidUsageOfConverter
    extends StorageSourceException {
  const StorageSourceResultInvalidUsageOfConverter([
    super.message,
    super.source,
    super.stacktrace,
  ]);
}
