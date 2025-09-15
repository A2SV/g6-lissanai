import 'package:equatable/equatable.dart';

abstract class StreakEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FreezeStreakEvent extends StreakEvent {}

class GetActivityCalendarEvent extends StreakEvent {}

class GetStreakInfoEvent extends StreakEvent {}
