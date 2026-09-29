abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A local cache error occurred.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'An authentication error occurred.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed.']);
}
