import 'dart:async';

class CallbackCompleter<T> {
  CallbackCompleter();

  Completer<T>? _completer;

  bool get isInProgress => _completer != null && !_completer!.isCompleted;

  Future<T>? get future => _completer?.future;

  Future<T> run(Future<T> Function() callback) async {
    if (_completer != null) {
      return _completer!.future;
    }

    final completer = Completer<T>();
    _completer = completer;

    Future(
      () async {
        try {
          final res = await callback();
          completer.complete(res);
        } catch (e, st) {
          completer.completeError(e, st);
        }
      },
    )..whenComplete(() {
        return _completer = null;
      });

    return completer.future;

    // TODO
  }
}
