part of 'practice_speaking_bloc.dart';

abstract class PracticeSpeakingEvent extends Equatable {
  const PracticeSpeakingEvent();
  @override
  List<Object?> get props => [];
}


class StartPracticeSessionEvent extends PracticeSpeakingEvent {
  final String type;
  const StartPracticeSessionEvent({required this.type});
}

class EndPracticeSessionEvent extends PracticeSpeakingEvent {
  final String sessionId;
  const EndPracticeSessionEvent({required this.sessionId});
}

class GetInterviewQuestionsEvent extends PracticeSpeakingEvent {
  const GetInterviewQuestionsEvent();
}

class SubmitAnswerEvent extends PracticeSpeakingEvent {
  final String answer;
  const SubmitAnswerEvent({required this.answer});

  @override
  List<Object?> get props => [answer];
}


class InitSpeechEvent extends PracticeSpeakingEvent {}
class StartListeningEvent extends PracticeSpeakingEvent {}
class StopListeningEvent extends PracticeSpeakingEvent {}


class SpeechResultEvent extends PracticeSpeakingEvent {
  final String recognizedWords;
  const SpeechResultEvent(this.recognizedWords);
  @override
  List<Object?> get props => [recognizedWords];
}

class SpeechErrorEvent extends PracticeSpeakingEvent {
  final String message;
  const SpeechErrorEvent(this.message);
  @override
  List<Object?> get props => [message];
}

class MoveToPreviousQuestionEvent extends PracticeSpeakingEvent {}
class MoveToNextQuestionEvent extends PracticeSpeakingEvent {}
