import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/check_grammar_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/email_draft_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/email_improve_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/get_sentence_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/send_pronunciation_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_event.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_state.dart';

class WrittingBloc extends Bloc<WrittingEvent, WrittingState> {
  final CheckGrammarUsecase checkGrammarUsecase;
  final EmailDraftUsecase getEmailDraftUsecase;
  final EmailImproveUsecase improveEmailUsecase;
  final GetSentenceUsecase getSentenceUsecase;
  final SendPronunciationUsecase sendPronunciationUsecase;

  WrittingBloc({
    required this.checkGrammarUsecase,
    required this.getEmailDraftUsecase,
    required this.improveEmailUsecase,
    required this.getSentenceUsecase,
    required this.sendPronunciationUsecase,
  }) : super(WrittingInitial()) {
    on<CheckGrammarEvent>(_onCheckGrammerEvent);
    on<GenerateEmailDraft>(_onGenerateEmailDraft);
    on<ImproveEmailEvent>(_onImproveEmail);

    on<GetSentenceEvent>((event, emit) async {
      emit(SentenceLoading());
      debugPrint('Bloc event received: GetSentenceEvent');
      final result = await getSentenceUsecase();
      result.fold(
        (failure) => emit(GrammarError(message: failure.message)),
        (success) => emit(SentenceLoaded(sentence: success)),
      );
    });

    on<SendPronunciationEvent>((event, emit) async {
      emit(PronunciationLoading());
      debugPrint('Bloc event received: SendPronunciationEvent');
      final result = await sendPronunciationUsecase(
        event.targetText,
        File(event.audioFilePath),
      );
      result.fold(
        (failure) => emit(GrammarError(message: failure.message)),
        (success) => emit(
          PronunciationLoaded(feedback: success, sentence: event.targetText),
        ),
      );
    });
  }

  void _onCheckGrammerEvent(
    CheckGrammarEvent event,
    Emitter<WrittingState> emit,
  ) async {
    emit(GrammarLoading());
    debugPrint('Bloc event received: ${event.englishText}');
    final result = await checkGrammarUsecase(event.englishText);
    result.fold(
      (failure) => emit(GrammarError(message: failure.message)),
      (success) => emit(GrammarLoaded(grammarResult: success)),
    );
  }

  void _onGenerateEmailDraft(
    GenerateEmailDraft event,
    Emitter<WrittingState> emit,
  ) async {
    emit(EmailDraftLoading());

    final result = await getEmailDraftUsecase(
      amharicPrompt: event.amharicPrompt,
      tone: event.tone,
      type: event.type,
    );
    result.fold(
      (failure) => emit(EmailDraftError(message: failure.message)),
      (success) => emit(EmailDraftLoaded(emailDraft: success)),
    );
  }

  void _onImproveEmail(
    ImproveEmailEvent event,
    Emitter<WrittingState> emit,
  ) async {
    emit(ImproveEmailLoading());

    final result = await improveEmailUsecase(
      tone: event.tone,
      type: event.type,
      userEmail: event.userEmail,
    );
    result.fold(
      (failure) => emit(ImproveEmailError(message: failure.message)),
      (success) => emit(ImproveEmailLoaded(improvedEmail: success)),
    );
  }
}
