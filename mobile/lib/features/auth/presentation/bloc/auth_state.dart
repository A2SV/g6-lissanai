import 'package:lissan_ai/features/auth/domain/entities/user.dart';

abstract class AuthState {}

class InitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState({required this.message});
}

class SignedOutState extends AuthState {}

class SignedUpState extends AuthState {}

class AuthenticatedState extends AuthState {
  final User user;
  AuthenticatedState(this.user);
}

class UnAuthenticatedState extends AuthState {}
