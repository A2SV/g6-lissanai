import 'package:lissan_ai/features/writting_assistant/domain/entities/saved_email.dart';

abstract class SavedEmailState {}

class SavedEmailInitial extends SavedEmailState {}

class SavedEmailLoading extends SavedEmailState {}

class EmailSaved extends SavedEmailState {}

class SavedEmailsLoaded extends SavedEmailState {
  final List<SavedEmail> emails;

  SavedEmailsLoaded({required this.emails});
}

class SavedEmailDeleted extends SavedEmailState {}

class AllEmailsCleared extends SavedEmailState {}

class SavedEmailError extends SavedEmailState {
  final String message;

  SavedEmailError({required this.message});
}
