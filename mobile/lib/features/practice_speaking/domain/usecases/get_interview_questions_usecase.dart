import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/interview_question.dart';
import 'package:lissan_ai/features/practice_speaking/domain/repositories/practice_speaking_repository.dart';

class GetInterviewQuestionsUsecase {
  final PracticeSpeakingRepository repository;
  GetInterviewQuestionsUsecase({required this.repository});

  Future<Either<Failure, InterviewQuestion>> call(String sessionId){
    return repository.getInterviewQuestion(sessionId);
  }

}