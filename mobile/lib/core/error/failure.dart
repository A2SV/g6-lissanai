import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String message;
  const Failure({required this.message});
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message});
}
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}
class ConflictFailure extends Failure {
  const ConflictFailure({required super.message});
}
