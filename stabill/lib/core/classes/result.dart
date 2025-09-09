class Result<T> {
  final T? data;
  final Object? error;

  const Result({this.data, this.error})
      : assert((data == null) != (error == null),
            'Either data or error must be provided, but not both.');

  factory Result.failure(Object error) => Result(error: error);
  factory Result.success(T data) => Result(data: data);

  bool get isFailure => error != null;
  bool get isSuccess => data != null;
}
