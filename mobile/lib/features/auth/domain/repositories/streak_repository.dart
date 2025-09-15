import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/auth/domain/entities/streak_calendar.dart';
import 'package:lissan_ai/features/auth/domain/entities/streak_info.dart';

abstract class StreakRepository {
  Future<Either<Failure, Unit>> freezeStreak();
  Future<Either<Failure, StreakCalendar>> getActivityCalendar();
  Future<Either<Failure, StreakInfo>> getStreakInfo();
  Future<Either<Failure, Unit>> recordActivity();
}
