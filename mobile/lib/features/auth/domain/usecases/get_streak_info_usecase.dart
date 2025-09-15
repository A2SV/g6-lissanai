import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/auth/domain/entities/streak_info.dart';
import 'package:lissan_ai/features/auth/domain/repositories/streak_repository.dart';

class GetStreakInfoUsecase {
  final StreakRepository repository;
  GetStreakInfoUsecase({required this.repository});
  Future<Either<Failure, StreakInfo>> call() {
    return repository.getStreakInfo();
  }
}
