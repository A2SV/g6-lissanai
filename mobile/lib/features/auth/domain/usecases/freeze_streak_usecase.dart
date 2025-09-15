import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/auth/domain/repositories/streak_repository.dart';

class FreezeStreakUsecase {
  final StreakRepository repository;
  FreezeStreakUsecase({required this.repository});
  Future<Either<Failure, Unit>> call() {
    return repository.freezeStreak();
  }
}
