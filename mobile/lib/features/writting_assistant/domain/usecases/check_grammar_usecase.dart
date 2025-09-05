import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/grammar_result.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/grammar_repository.dart';

class CheckGrammarUsecase {
  final GrammarRepository repository;

  CheckGrammarUsecase({required this.repository});

  Future<Either<Failure, GrammarResult>> call(String englishText) {
    return repository.checkGrammar(englishText);
  }
}
