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

/// Generic — not specific to `alerts`. Any feature operating on an id that
/// may not exist (e.g. `setpoints` later) can reuse this instead of a
/// feature-specific not-found failure.
class NotFoundFailure extends Failure {
  final String message;

  const NotFoundFailure(this.message);
}

/// Generic — not specific to `setpoints`. Any write that must check the
/// requesting user's role (e.g. a future feature gating another mutation
/// behind `UserRole.administrador`) reuses this instead of inventing its
/// own feature-specific authorization failure.
class UnauthorizedFailure extends Failure {
  final String message;

  const UnauthorizedFailure(this.message);
}
