import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/auth/domain/entities/streak_calendar.dart';
import 'package:lissan_ai/features/auth/domain/repositories/streak_repository.dart';

class GetActivityCalendarUsecase {
  final StreakRepository repository;
  GetActivityCalendarUsecase({required this.repository});
  Future<Either<Failure, StreakCalendar>> call() {
    return repository.getActivityCalendar();
  }
}
