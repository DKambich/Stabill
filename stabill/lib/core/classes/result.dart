class Result<T> {
  final T? data;
  final Object? error;
  final bool _isSuccess;

  const Result({this.data, this.error})
      : _isSuccess = data != null,
        assert((data == null) != (error == null),
            'Either data or error must be provided, but not both.');

  factory Result.failure(Object error) =>
      Result._(error: error, isSuccess: false);

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  const Result._({this.data, this.error, required bool isSuccess})
      : _isSuccess = isSuccess;

  bool get isFailure => !_isSuccess;
  bool get isSuccess => _isSuccess;
}
