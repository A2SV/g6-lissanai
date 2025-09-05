import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/pronunciation_feedback.dart';

abstract class PronunciationRepository {
  Future<Either<Failure, PronunciationFeedback>> sendPronunciation(
    String sentence,
    File audioFile,
  );
}
