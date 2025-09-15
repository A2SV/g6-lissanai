import 'package:bloc/bloc.dart';
import 'package:lissan_ai/features/auth/domain/repositories/streak_repository.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/streak_event.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/streak_state.dart';

class StreakBloc extends Bloc<StreakEvent, StreakState> {
  final StreakRepository repository;

  StreakBloc({required this.repository}) : super(StreakInitial()) {
    on<FreezeStreakEvent>(_onFreezeStreak);
    on<GetActivityCalendarEvent>(_onGetCalendar);
    on<GetStreakInfoEvent>(_onGetInfo);
  }

  Future<void> _onFreezeStreak(
    FreezeStreakEvent event,
    Emitter<StreakState> emit,
  ) async {
    emit(StreakLoading());
    final result = await repository.freezeStreak();
    result.fold(
      (failure) => emit(StreakError(message: failure.toString())),
      (_) => emit(StreakFrozen()),
    );
  }

  Future<void> _onGetCalendar(
    GetActivityCalendarEvent event,
    Emitter<StreakState> emit,
  ) async {
    emit(StreakLoading());
    final result = await repository.getActivityCalendar();
    result.fold(
      (failure) => emit(StreakError(message: failure.toString())),
      (calendar) => emit(ActivityCalendarLoaded(calendar: calendar)),
    );
  }

  Future<void> _onGetInfo(
    GetStreakInfoEvent event,
    Emitter<StreakState> emit,
  ) async {
    emit(StreakLoading());
    final result = await repository.getStreakInfo();
    result.fold(
      (failure) => emit(StreakError(message: failure.toString())),
      (info) => emit(StreakInfoLoaded(streakInfo: info)),
    );
  }
}
