import 'dart:async';

extension FutureOrGetFutureExtension<T> on FutureOr<T> {
  Future<T> get future {
    if (this is Future<T>) {
      return this as Future<T>;
    } else {
      return Future.value(this as T);
    }
  }
}
