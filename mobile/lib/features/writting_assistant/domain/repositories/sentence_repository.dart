import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/sentence.dart';

abstract class SentenceRepository {
  Future<Either<Failure,Sentence>> getSentence();
}