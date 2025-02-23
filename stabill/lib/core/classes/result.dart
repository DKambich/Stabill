class Failure<T> extends Result<T> {
  @override
  final Object error;
  const Failure(this.error);
}

sealed class Result<T> {
  const Result();

  factory Result.failure(Object error) = Failure<T>;
  factory Result.success(T data) = Success<T>;

  T? get data => this is Success<T> ? (this as Success<T>).data : null;
  Object? get error => this is Failure<T> ? (this as Failure<T>).error : null;

  bool get isFailure => this is Failure<T>;
  bool get isSuccess => this is Success<T>;
}

class Success<T> extends Result<T> {
  @override
  final T data;
  const Success(this.data);
}
