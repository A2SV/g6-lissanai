import 'package:lissan_ai/features/writting_assistant/domain/entities/pronunciation_feedback.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/sentence.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_state.dart';

abstract class WrittingEvent {}

class CheckGrammarEvent extends WrittingEvent {
  final String englishText;

  CheckGrammarEvent({required this.englishText});
}

class GenerateEmailDraft extends WrittingEvent {
  final String amharicPrompt;
  final String tone;
  final String type;

  GenerateEmailDraft(this.amharicPrompt, this.tone, this.type);

  @override
  List<Object> get props => [amharicPrompt, tone, type];
}

class ImproveEmailEvent extends WrittingEvent {
  final String userEmail;
  final String tone;
  final String type;

  ImproveEmailEvent(this.userEmail, this.tone, this.type);

  @override
  List<Object> get props => [userEmail, tone, type];
}

class SendPronunciationEvent extends WrittingEvent {
  final String targetText;
  final String audioFilePath;

  SendPronunciationEvent({
    required this.targetText,
    required this.audioFilePath,
  });
}

class GetSentenceEvent extends WrittingEvent {}

class SentenceLoaded extends WrittingState {
  final Sentence sentence;

  SentenceLoaded({required this.sentence});
}

class SentenceLoading extends WrittingState {}

class SentenceError extends WrittingState {
  final String message;

  SentenceError({required this.message});
}

class SentenceInitial extends WrittingState {}

class PronunciationLoading extends WrittingState {}

class PronunciationLoaded extends WrittingState {
  final PronunciationFeedback feedback;
  final String sentence; // <-- Add this field

  PronunciationLoaded({required this.feedback, required this.sentence});

  @override
  List<Object> get props => [feedback, sentence];
}

// save email
class SaveEmailDraftEvent extends WrittingEvent {
  final String subject;
  final String body;

  SaveEmailDraftEvent({required this.subject, required this.body});
}

class SaveImprovedEmailEvent extends WrittingEvent {
  final String subject;
  final String body;

  SaveImprovedEmailEvent({required this.subject, required this.body});
}
