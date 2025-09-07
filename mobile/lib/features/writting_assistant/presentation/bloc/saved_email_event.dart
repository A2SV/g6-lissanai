import 'package:lissan_ai/features/writting_assistant/domain/entities/saved_email.dart';

abstract class SavedEmailEvent {}

class SaveEmailEvent extends SavedEmailEvent {
  final SavedEmail email;

  SaveEmailEvent({required this.email});
}

class LoadSavedEmailsEvent extends SavedEmailEvent {}

class DeleteSavedEmailEvent extends SavedEmailEvent {
  final String id;

  DeleteSavedEmailEvent({required this.id});
}

class ClearAllEmailsEvent extends SavedEmailEvent {}
