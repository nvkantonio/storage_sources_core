import 'dart:async';
import 'package:storage_sources_core/storage_sources_core.dart';

mixin StorageStreamValueGetDataLatestMixin<T> implements StorageStreamValue<T> {
  @override
  FutureOr<SR<T>> fetchData() async {
    SR<T>? latestOkResponse;
    SR<T>? latestErrorResponse;

    await for (final e in dataStream()) {
      switch (e) {
        case OkStorageSourceResult<T> result:
          latestOkResponse = result;
        case ErrorStorageSourceResult<T> result:
          latestErrorResponse = result;
        default:
          break;
      }
    }

    if (latestOkResponse != null) return latestOkResponse;
    if (latestErrorResponse != null) return latestErrorResponse;
    return const UndefinedStorageSourceResult();
  }
}
