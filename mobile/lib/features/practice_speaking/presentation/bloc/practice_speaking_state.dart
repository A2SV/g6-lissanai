part of 'practice_speaking_bloc.dart';

enum BlocStatus {
  initial,
  loading,
  questionLoading,
  sessionStarted,
  sessionEnded,
  questionsLoaded,
  feedbackReceived,
  error,
}

class PracticeSpeakingState extends Equatable {
  final BlocStatus status;
  final dynamic session; 
  final InterviewQuestion? currentQuestion;
  final dynamic feedback; 
  final String? error;
  final List<InterviewQuestion> questions;
  final int currentQuestionIndex;
  final dynamic endSessionFeedback;

  
  final String recognizedText;
  final bool isListening;

  const PracticeSpeakingState({
    this.status = BlocStatus.initial,
    this.session,
    this.currentQuestion,
    this.feedback,
    this.error,
    this.recognizedText = '',
    this.isListening = false,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.endSessionFeedback,
  });

  PracticeSpeakingState copyWith({
    BlocStatus? status,
    dynamic session,
    InterviewQuestion? currentQuestion,
    dynamic feedback,
    String? error,
    String? recognizedText,
    bool? isListening,
    List<InterviewQuestion>? questions,
    int? currentQuestionIndex,
    dynamic endSessionFeedback,
  }) {
    return PracticeSpeakingState(
      status: status ?? this.status,
      session: session ?? this.session,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      feedback: feedback ?? this.feedback,
      error: error,
      recognizedText: recognizedText ?? this.recognizedText,
      isListening: isListening ?? this.isListening,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      endSessionFeedback: endSessionFeedback ?? this.endSessionFeedback,
    );
  }

  @override
  List<Object?> get props =>
      [status, session, currentQuestion, feedback, error, recognizedText, isListening, endSessionFeedback];
}
