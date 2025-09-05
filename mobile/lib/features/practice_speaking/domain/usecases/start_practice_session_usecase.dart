import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/practice_session_start.dart';
import 'package:lissan_ai/features/practice_speaking/domain/repositories/practice_speaking_repository.dart';

class StartPracticeSessionUsecase {
  final PracticeSpeakingRepository repository;
  StartPracticeSessionUsecase({required this.repository});

  Future<Either<Failure, PracticeSessionStart>> call(String type){
    return repository.startPracticeSession(type);
  }
}