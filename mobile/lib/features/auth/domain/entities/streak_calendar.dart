// ignore_for_file: non_constant_identifier_names

import 'package:lissan_ai/features/auth/domain/entities/summary.dart';
import 'package:lissan_ai/features/auth/domain/entities/week.dart';

class StreakCalendar {
  int? active_days;
  int? current_streak;
  int? longest_streak;
  Summary? summary;
  int? total_days;
  List<Week>? weeks;
  int? year;

  StreakCalendar({
    this.active_days,
    this.current_streak,
    this.longest_streak,
    this.summary,
    this.total_days,
    this.weeks,
    this.year,
  });
}
