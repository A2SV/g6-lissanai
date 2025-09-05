import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/grammar_result.dart';

abstract class GrammarRepository {
  Future<Either<Failure, GrammarResult>> checkGrammar(String englishText);
}
