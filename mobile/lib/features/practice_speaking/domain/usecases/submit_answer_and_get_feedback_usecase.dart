import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/answer_feed_back.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/user_answer.dart';
import 'package:lissan_ai/features/practice_speaking/domain/repositories/practice_speaking_repository.dart';

class SubmitAnswerAndGetFeedbackUsecase {
  final PracticeSpeakingRepository repository;
  SubmitAnswerAndGetFeedbackUsecase({required this.repository});

  Future<Either<Failure, AnswerFeedback>> call(UserAnswer answer){
    return repository.submitAndGetAnswer(answer);
  }
}