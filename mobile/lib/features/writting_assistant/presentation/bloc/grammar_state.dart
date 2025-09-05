import 'package:lissan_ai/features/writting_assistant/domain/entities/grammar_result.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/pronunciation_feedback.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/sentence.dart';

abstract class GrammarState {}

class GrammarInitial extends GrammarState {}

class GrammarLoading extends GrammarState {}

class GrammarLoaded extends GrammarState {
  final GrammarResult grammarResult;

  GrammarLoaded({required this.grammarResult});
}

class GrammarError extends GrammarState {
  final String message;

  GrammarError({required this.message});
}

class SentenceLoaded extends GrammarState {
  final Sentence sentence;

  SentenceLoaded({required this.sentence});
}

class SentenceLoading extends GrammarState {}
class SentenceError extends GrammarState {
  final String message;

  SentenceError({required this.message});
}
class SentenceInitial extends GrammarState {}

class PronunciationLoading extends GrammarState {}

class PronunciationLoaded extends GrammarState {
  final PronunciationFeedback feedback;
  final String sentence; // <-- Add this field

  PronunciationLoaded({required this.feedback, required this.sentence});

  @override
  List<Object> get props => [feedback, sentence];
}
