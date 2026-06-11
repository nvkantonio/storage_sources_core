import 'dart:async';
import '../../storage_sources.dart';

class NetworkSource<T> extends CallbackStorageSource<T> {
  const NetworkSource(Future<T> Function() super.request);

  @override
  Future<SR<T>> fetchData() async => super.fetchData();
}
