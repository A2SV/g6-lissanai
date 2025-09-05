import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/sentence.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/sentence_repository.dart';

class GetSentenceUsecase {
  final SentenceRepository repository;
  GetSentenceUsecase(this.repository);
  Future<Either<Failure, Sentence>> call() {
    return repository.getSentence();
  }
}