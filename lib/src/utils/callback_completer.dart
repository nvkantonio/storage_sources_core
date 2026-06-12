import 'dart:async';

final class NoArgument {
  const NoArgument();

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) => other is NoArgument;
}

final class _CompleterWithArgument<T> {
  _CompleterWithArgument(this.equalityArg) : completer = Completer<T>();

  final Completer<T> completer;
  final dynamic equalityArg;
}

class CallbackCompleter<T> {
  CallbackCompleter();

  _CompleterWithArgument<T>? _completerWithArg;

  Completer<T>? get _completer => _completerWithArg?.completer;

  bool get isInProgress => _completer != null && !_completer!.isCompleted;

  Future<T>? get future => _completer?.future;

  Future<T> run(Future<T> Function() callback,
      [dynamic equalityArg = const NoArgument()]) {
    final currentCompleterWithArg = _completerWithArg;

    if (currentCompleterWithArg == null) {
      final newCompleterWithArg = _CompleterWithArgument<T>(equalityArg);
      _completerWithArg = newCompleterWithArg;

      return _runCompleter(callback, newCompleterWithArg);
    }

    if (equalityArg == currentCompleterWithArg.equalityArg) {
      return currentCompleterWithArg.completer.future;
    }

    final newCompleterWithArg = _CompleterWithArgument<T>(equalityArg);
    _completerWithArg = newCompleterWithArg;

    final currentCompleterFuture =
        Future<dynamic>(() => currentCompleterWithArg.completer.future);

    return currentCompleterFuture.catchError((_) => null).then(
      (_) {
        return _runCompleter(callback, newCompleterWithArg);
      },
    );
  }

  Future<T> _runCompleter(Future<T> Function() callback,
      _CompleterWithArgument<T> completerWithArg) {
    final completer = completerWithArg.completer;

    Future(
      () async {
        try {
          final res = await callback();
          completer.complete(res);
        } catch (e, st) {
          completer.completeError(e, st);
        }
      },
    ).whenComplete(() {
      if (identical(completerWithArg, _completerWithArg)) {
        _completerWithArg = null;
      }
    });

    return completer.future;
  }
}
