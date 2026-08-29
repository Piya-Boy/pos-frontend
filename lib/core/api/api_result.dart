import 'app_error.dart';

class ApiResult<T> {
  const ApiResult({required this.ok, this.data, this.error});

  final bool ok;
  final T? data;
  final AppError? error;
}
