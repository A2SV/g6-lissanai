import 'package:equatable/equatable.dart';

abstract class AppException extends Equatable implements Exception {
  final String message;
  const AppException({required this.message});
  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException({required super.message});
}

class NetworkException extends AppException {
  const NetworkException({required super.message});
}

class CacheException extends AppException {
  const CacheException({required super.message});
}

class UnAuthorizedException extends AppException {
  const UnAuthorizedException({required super.message});
}

class BadRequestException extends AppException {
  const BadRequestException({required super.message});
}

class ConflictException extends AppException {
  const ConflictException({required super.message});
}
