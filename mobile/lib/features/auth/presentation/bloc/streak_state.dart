import 'package:lissan_ai/features/auth/domain/entities/streak_calendar.dart';
import 'package:lissan_ai/features/auth/domain/entities/streak_info.dart';

abstract class StreakState {}

class StreakInitial extends StreakState {}

class StreakLoading extends StreakState {}

class StreakFrozen extends StreakState {}

class RecordActivitySuccess extends StreakState {}

class ActivityCalendarLoaded extends StreakState {
  final StreakCalendar calendar;
  ActivityCalendarLoaded({required this.calendar});
}

class StreakInfoLoaded extends StreakState {
  final StreakInfo streakInfo;
  StreakInfoLoaded({required this.streakInfo});
}

class StreakError extends StreakState {
  final String message;
  StreakError({required this.message});
}
