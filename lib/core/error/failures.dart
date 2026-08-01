/// `Either<Failure, T>` is the error-handling convention for `domain` and
/// `data` across the whole app, not just `auth`. `presentation` is the only
/// layer allowed to `.fold()` it — inside the feature's controller — and from
/// there exposes a plain state to widgets. Widgets never import `fpdart`
/// directly.
sealed class Failure {
  const Failure();
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure();
}

class NoSessionFailure extends Failure {
  const NoSessionFailure();
}

class UnexpectedFailure extends Failure {
  final String message;

  const UnexpectedFailure(this.message);
}
