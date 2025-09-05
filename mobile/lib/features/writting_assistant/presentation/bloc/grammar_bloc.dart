import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/check_grammar_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/get_sentence_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/send_pronunciation_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/grammar_event.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/grammar_state.dart';

class GrammarBloc extends Bloc<GrammarEvent, GrammarState> {
  final CheckGrammarUsecase checkGrammarUsecase;
  final GetSentenceUsecase getSentenceUsecase;
  final SendPronunciationUsecase sendPronunciationUsecase;

  GrammarBloc({
    required this.sendPronunciationUsecase,
    required this.checkGrammarUsecase,
    required this.getSentenceUsecase,
  }) : super(GrammarInitial()) {
    on<CheckGrammarEvent>((event, emit) async {
      emit(GrammarLoading());
      debugPrint('Bloc event received: ${event.englishText}');
      final result = await checkGrammarUsecase(event.englishText);
      result.fold(
        (failure) => emit(GrammarError(message: failure.message)),
        (success) => emit(GrammarLoaded(grammarResult: success)),
      );
    });

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
        (success) => emit(PronunciationLoaded(feedback: success, sentence: event.targetText)),
      );
    
    });
  }
}
