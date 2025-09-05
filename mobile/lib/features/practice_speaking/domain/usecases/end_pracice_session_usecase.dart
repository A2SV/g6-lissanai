import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/practice_session_result.dart';
import 'package:lissan_ai/features/practice_speaking/domain/repositories/practice_speaking_repository.dart';

class EndPraciceSessionUsecase {
  final PracticeSpeakingRepository repository;
  EndPraciceSessionUsecase({required this.repository});

  Future<Either<Failure, PracticeSessionResult>> call(String sessionId){
    return repository.endPracticeSession(sessionId);
  }
}