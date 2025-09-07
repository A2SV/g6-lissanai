import 'package:lissan_ai/features/writting_assistant/domain/entities/email_draft.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/grammar_result.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/email_improve.dart';

abstract class WrittingState {}

class WrittingInitial extends WrittingState {}

// for grammer
class GrammarLoading extends WrittingState {}

class GrammarLoaded extends WrittingState {
  final GrammarResult grammarResult;

  GrammarLoaded({required this.grammarResult});
}

class GrammarError extends WrittingState {
  final String message;

  GrammarError({required this.message});
}

//--- for email --//
// email draft
class EmailDraftLoading extends WrittingState {}

class EmailDraftLoaded extends WrittingState {
  final EmailDraft emailDraft;

  EmailDraftLoaded({required this.emailDraft});

  @override
  List<Object> get props => [emailDraft];
}

class EmailDraftError extends WrittingState {
  final String message;

  EmailDraftError({required this.message});

  @override
  List<Object> get props => [message];
}

// email improve
class ImproveEmailLoading extends WrittingState {}

class ImproveEmailLoaded extends WrittingState {
  final EmailImprove improvedEmail;

  ImproveEmailLoaded({required this.improvedEmail});

  @override
  List<Object> get props => [improvedEmail];
}

class ImproveEmailError extends WrittingState {
  final String message;

  ImproveEmailError({required this.message});

  @override
  List<Object> get props => [message];
}

// save email
class EmailDraftSaved extends WrittingState {
  final EmailDraft emailDraft;

  EmailDraftSaved({required this.emailDraft});
}

class ImprovedEmailSaved extends WrittingState {
  final EmailImprove improvedEmail;

  ImprovedEmailSaved({required this.improvedEmail});
}
