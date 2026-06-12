import 'dart:async';
import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';

import 'storage_source_result_exceptions.dart';

typedef SR<T> = StorageSourceResult<T>;
typedef FSR<T> = FutureOr<SR<T>>;

typedef OnErrorCallback = Function(Object e, StackTrace st);

enum StorageSourceResultType { ok, error, undefined }

abstract interface class StorageSourceResultInterface<T> {
  T get value;
  Object get error;

  T? get valueOrNull;
  Object? get errorOrNull;

  bool get isUndefined;
  bool get isOk;
  bool get isError;

  StorageSourceResult<T> get asStorageSourceResult;

  StorageSourceResultInterface<R> convert<R>([R Function(T value)? converter]);
}

/// Tristate abstraction for a state of value.
/// [OkStorageSourceResult], [ErrorStorageSourceResult], [UndefinedStorageSourceResult].
sealed class StorageSourceResult<T>
    with EquatableMixin
    implements StorageSourceResultInterface<T> {
  const StorageSourceResult({this.handleErrorCallback});

  /// When [StorageSourceResult] should throw exception on calling of invalid data,
  ///  handleErrorCallback will rewrite default throw behavior to throw
  ///  another exception or return value of [T] instead.
  final OnErrorCallback? handleErrorCallback;

  @override
  StorageSourceResult<T> get asStorageSourceResult => this;

  @override
  StorageSourceResult<R> convert<R>([R Function(T value)? converter]);

  static StorageSourceResult ok<T>(T value) => OkStorageSourceResult<T>(value);

  static StorageSourceResult undefined<T>() =>
      UndefinedStorageSourceResult<T>();

  static StorageSourceResult withError<T>(
    Object error, [
    StackTrace? stackTrace,
  ]) =>
      ErrorStorageSourceResult<T>(error, stackTrace: stackTrace);

  static StorageSourceResult<T> check<T>(
    T? Function() fn, {
    OnErrorCallback? onErrorCallback,
  }) {
    try {
      if (fn() case T res) {
        return OkStorageSourceResult(res, handleErrorCallback: onErrorCallback);
      } else {
        return UndefinedStorageSourceResult(
          handleErrorCallback: onErrorCallback,
        );
      }
    } catch (e, st) {
      return ErrorStorageSourceResult(
        e,
        stackTrace: st,
        handleErrorCallback: onErrorCallback,
      );
    }
  }

  static FutureOr<StorageSourceResult<T>> checkAsync<T>(
    FutureOr<T?> Function() fn, {
    OnErrorCallback? onErrorCallback,
  }) async {
    try {
      final fnResult = await fn();

      if (fnResult case T res) {
        return OkStorageSourceResult(res, handleErrorCallback: onErrorCallback);
      } else {
        return UndefinedStorageSourceResult(
          handleErrorCallback: onErrorCallback,
        );
      }
    } catch (e, st) {
      return ErrorStorageSourceResult(
        e,
        stackTrace: st,
        handleErrorCallback: onErrorCallback,
      );
    }
  }

  static R _errorHandler<R>(
    Object e,
    StackTrace st, [
    OnErrorCallback? onErrorCallback,
  ]) {
    if (onErrorCallback != null) {
      final callback = onErrorCallback.call(e, st);

      if (callback is R) {
        return callback;
      } else if (callback != null) {
        dev.log(
          'Invalid use of "onErrorCallback" with type "${callback.runtimeType}" in StorageSourceResult. Expected type is $R',
        );
      }
    }

    Error.throwWithStackTrace(e, st);
  }

  @override
  List<Object?> get props => [
        valueOrNull,
        errorOrNull,
        isOk,
        isUndefined,
        isError,
      ];

  @override
  String toString() {
    return '$runtimeType(, valueOrNull:$valueOrNull, errorOrNull:$errorOrNull, handleErrorCallback:$handleErrorCallback, isOk:$isOk, isUndefined:$isUndefined, isError:$isError)';
  }
}

class OkStorageSourceResult<T> extends StorageSourceResult<T> {
  const OkStorageSourceResult(this.value, {super.handleErrorCallback});

  @override
  final T value;

  @override
  Object get error => StorageSourceResult._errorHandler(
        StorageSourceResultNotAnErrorException(
          'Required error on existing value of type $T',
          value,
        ),
        StackTrace.current,
        handleErrorCallback,
      );

  @override
  T? get valueOrNull => value;

  @override
  Object? get errorOrNull => null;

  @override
  bool get isUndefined => false;

  @override
  bool get isOk => true;

  @override
  bool get isError => false;

  @override
  OkStorageSourceResult<R> convert<R>([R Function(T value)? converter]) {
    final actualConverter = converter ?? (value) => value as R;

    final R convertedValue;

    try {
      convertedValue = actualConverter(value);
    } catch (e, st) {
      final Object actualException;

      if (converter == null) {
        throw StorageSourceResultInvalidUsageOfConverter(
            'Invalid usage of converter for $runtimeType', e, st);
      } else {
        actualException = e;
      }

      return StorageSourceResult._errorHandler(
        actualException,
        st,
        handleErrorCallback,
      );
    }

    return OkStorageSourceResult<R>(
      convertedValue,
      handleErrorCallback: handleErrorCallback,
    );
  }
}

sealed class NotOkStorageSourceResult<T> extends StorageSourceResult<T> {
  const NotOkStorageSourceResult({super.handleErrorCallback});

  @override
  bool get isOk => false;

  @override
  T? get valueOrNull => null;
}

class UndefinedStorageSourceResult<T> extends NotOkStorageSourceResult<T>
    implements StorageSourceResult<T> {
  const UndefinedStorageSourceResult({super.handleErrorCallback});

  @override
  T get value => StorageSourceResult._errorHandler(
        StorageSourceResultUndefinedValueException(
          'Required undefined value of type $T',
        ),
        StackTrace.current,
        handleErrorCallback,
      );

  @override
  Object get error => StorageSourceResult._errorHandler(
        StorageSourceResultNotAnErrorException(
          'Required error on undefined value of type $T',
          value,
        ),
        StackTrace.current,
        handleErrorCallback,
      );

  @override
  Object? get errorOrNull => null;

  @override
  bool get isUndefined => true;

  @override
  bool get isError => false;

  @override
  UndefinedStorageSourceResult<R> convert<R>(
          [R Function(T value)? converter]) =>
      UndefinedStorageSourceResult<R>(handleErrorCallback: handleErrorCallback);
}

class ErrorStorageSourceResult<T> extends NotOkStorageSourceResult<T>
    implements StorageSourceResult<T> {
  const ErrorStorageSourceResult(
    this.error, {
    this.stackTrace,
    super.handleErrorCallback,
  });

  final StackTrace? stackTrace;

  @override
  final Object error;

  @override
  T get value => StorageSourceResult._errorHandler(
      error, stackTrace ?? StackTrace.current, handleErrorCallback);

  @override
  Object? get errorOrNull => error;

  @override
  bool get isUndefined => false;

  @override
  bool get isError => true;

  @override
  ErrorStorageSourceResult<R> convert<R>([R Function(T value)? converter]) =>
      ErrorStorageSourceResult<R>(
        error,
        stackTrace: stackTrace,
        handleErrorCallback: handleErrorCallback,
      );
}
