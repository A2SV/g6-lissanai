import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/interview_question.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/user_answer.dart';
import 'package:lissan_ai/features/practice_speaking/domain/usecases/end_pracice_session_usecase.dart';
import 'package:lissan_ai/features/practice_speaking/domain/usecases/get_interview_questions_usecase.dart';
import 'package:lissan_ai/features/practice_speaking/domain/usecases/recognize_speech.dart';
import 'package:lissan_ai/features/practice_speaking/domain/usecases/start_practice_session_usecase.dart';
import 'package:lissan_ai/features/practice_speaking/domain/usecases/submit_answer_and_get_feedback_usecase.dart';

part 'practice_speaking_event.dart';
part 'practice_speaking_state.dart';

class PracticeSpeakingBloc
    extends Bloc<PracticeSpeakingEvent, PracticeSpeakingState> {
  final StartPracticeSessionUsecase startPracticeSessionUsecase;
  final EndPraciceSessionUsecase endPracticeSessionUsecase;
  final GetInterviewQuestionsUsecase getInterviewQuestionsUsecase;
  final SubmitAnswerAndGetFeedbackUsecase submitAndGetAnswerUsecase;
  final RecognizeSpeechUsecase recognizeSpeech;

  StreamSubscription<String>? _wordsSub;
  StreamSubscription<String>? _errorSub;

  PracticeSpeakingBloc({
    required this.startPracticeSessionUsecase,
    required this.endPracticeSessionUsecase,
    required this.getInterviewQuestionsUsecase,
    required this.submitAndGetAnswerUsecase,
    required this.recognizeSpeech,
  }) : super(const PracticeSpeakingState()) {
    on<StartPracticeSessionEvent>(_onStartSession);
    on<EndPracticeSessionEvent>(_onEndSession);
    on<GetInterviewQuestionsEvent>(_onGetQuestions);
    on<SubmitAnswerEvent>(_onSubmitAnswer);

    on<InitSpeechEvent>(_onInit);
    on<StartListeningEvent>(_onStartListening);
    on<StopListeningEvent>(_onStopListening);
    on<SpeechResultEvent>(_onSpeechResult);
    on<SpeechErrorEvent>(_onSpeechError);

    on<MoveToPreviousQuestionEvent>(_onMoveToPreviousQuestion);
    on<MoveToNextQuestionEvent>(_onMoveToNextQuestion);
    on<UpdateRecognizedTextEvent>((event, emit) {
      emit(state.copyWith(recognizedText: event.text));
    });
    on<ClearRecognizedTextEvent>((event, emit) {
    emit(state.copyWith(recognizedText: ''));
    });

  }

  Future<void> _onStartSession(
    StartPracticeSessionEvent event,
    Emitter<PracticeSpeakingState> emit,
  ) async {
    print('Speaking called');
    emit(state.copyWith(status: BlocStatus.loading));
    final result = await startPracticeSessionUsecase(event.type);
    result.fold(
      (failure) => emit(
        state.copyWith(status: BlocStatus.error, error: failure.toString()),
      ),
      (session) => emit(
        state.copyWith(status: BlocStatus.sessionStarted, session: session),
      ),
    );
  }

  Future<void> _onEndSession(
    EndPracticeSessionEvent event,
    Emitter<PracticeSpeakingState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final result = await endPracticeSessionUsecase(event.sessionId);
    result.fold(
      (failure) => emit(
        state.copyWith(status: BlocStatus.error, error: failure.toString()),
      ),
      (feedback) => emit(
        state.copyWith(
          status: BlocStatus.sessionEnded,
          endSessionFeedback: feedback,
        ),
      ),
    );
  }

  Future<void> _onGetQuestions(
    GetInterviewQuestionsEvent event,
    Emitter<PracticeSpeakingState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.questionLoading));

    if (state.session == null) {
      emit(
        state.copyWith(status: BlocStatus.error, error: 'Session not started'),
      );
      return;
    }

    final result = await getInterviewQuestionsUsecase(state.session.sessionId);
    result.fold(
      (failure) => emit(
        state.copyWith(status: BlocStatus.error, error: failure.toString()),
      ),
      (question) {
        final updateQuestions = List<InterviewQuestion>.from(state.questions)
          ..add(question);
        emit(
          state.copyWith(
            status: BlocStatus.questionsLoaded,
            currentQuestion: question,
            questions: updateQuestions,
            currentQuestionIndex: updateQuestions.length - 1,
          ),
        );
      },
    );
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<PracticeSpeakingState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final userAnswer = UserAnswer(
      sessionId: state.session.sessionId ?? '',
      transcript: event.answer,
    );
    final result = await submitAndGetAnswerUsecase(userAnswer);
    result.fold(
      (failure) => emit(
        state.copyWith(status: BlocStatus.error, error: failure.toString()),
      ),
      (feedback) => emit(
        state.copyWith(status: BlocStatus.feedbackReceived, feedback: feedback),
      ),
    );
  }

  Future<void> _onInit(
    InitSpeechEvent event,
    Emitter<PracticeSpeakingState> emit,
  ) async {
    await recognizeSpeech.init();

    _wordsSub = recognizeSpeech.recognizedWords.listen(
      (words) => add(SpeechResultEvent(words)),
    );
    _errorSub = recognizeSpeech.errors.listen(
      (error) => add(SpeechErrorEvent(error)),
    );
  }

  Future<void> _onStartListening(
    StartListeningEvent event,
    Emitter<PracticeSpeakingState> emit,
  ) async {
    await recognizeSpeech.startListening();
    emit(state.copyWith(isListening: true));
  }

  Future<void> _onStopListening(
    StopListeningEvent event,
    Emitter<PracticeSpeakingState> emit,
  ) async {
    await recognizeSpeech.stopListening();
    emit(state.copyWith(isListening: false));
  }

  void _onSpeechResult(
    SpeechResultEvent event,
    Emitter<PracticeSpeakingState> emit,
  ) {
    emit(state.copyWith(recognizedText: event.recognizedWords));
  }

  void _onSpeechError(
    SpeechErrorEvent event,
    Emitter<PracticeSpeakingState> emit,
  ) {
    emit(state.copyWith(error: event.message, isListening: false));
  }

  Future<void> _onMoveToPreviousQuestion(
    MoveToPreviousQuestionEvent event,
    Emitter<PracticeSpeakingState> emit,
  ) async {
    if (state.currentQuestionIndex > 0) {
      final newIndex = state.currentQuestionIndex - 1;
      emit(
        state.copyWith(
          currentQuestionIndex: newIndex,
          currentQuestion: state.questions[newIndex],
        ),
      );
    }
  }

  Future<void> _onMoveToNextQuestion(
    MoveToNextQuestionEvent event,
    Emitter<PracticeSpeakingState> emit,
  ) async {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      final newIndex = state.currentQuestionIndex + 1;
      emit(
        state.copyWith(
          currentQuestionIndex: newIndex,
          currentQuestion: state.questions[newIndex],
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _wordsSub?.cancel();
    _errorSub?.cancel();
    return super.close();
  }
}
