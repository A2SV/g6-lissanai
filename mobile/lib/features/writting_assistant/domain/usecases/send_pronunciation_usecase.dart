import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/pronunciation_feedback.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/pronunciation_repository.dart';

class SendPronunciationUsecase {
  final PronunciationRepository repository;

  SendPronunciationUsecase(this.repository);

  Future<Either<Failure, PronunciationFeedback>> call(
    String sentence,
    File audioFile,
  ) {
    return repository.sendPronunciation(sentence, audioFile);
  }
}
