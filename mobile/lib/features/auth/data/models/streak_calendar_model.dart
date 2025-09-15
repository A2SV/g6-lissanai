import 'package:lissan_ai/features/auth/data/models/summary_model.dart';
import 'package:lissan_ai/features/auth/domain/entities/streak_calendar.dart';
import 'package:lissan_ai/features/auth/domain/entities/summary.dart';
import 'package:lissan_ai/features/auth/domain/entities/week.dart';
import 'package:lissan_ai/features/auth/data/models/week_model.dart';

class StreakCalendarModel extends StreakCalendar {
  StreakCalendarModel({
    int? active_days,
    int? current_streak,
    int? longest_streak,
    Summary? summary,
    int? total_days,
    List<Week>? weeks,
    int? year,
  }) : super(
         active_days: active_days,
         current_streak: current_streak,
         longest_streak: longest_streak,
         summary: summary,
         total_days: total_days,
         weeks: weeks,
         year: year,
       );

  factory StreakCalendarModel.fromJson(Map<String, dynamic> json) {
    return StreakCalendarModel(
      active_days: json['active_days'],
      current_streak: json['current_streak'],
      longest_streak: json['longest_streak'],
      summary: json['summary'] != null
          ? SummaryModel.fromJson(json['summary'])
          : null,
      total_days: json['total_days'],
      weeks: json['weeks'] != null
          ? (json['weeks'] as List).map((e) => WeekModel.fromJson(e)).toList()
          : null,
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "active_days": active_days,
      "current_streak": current_streak,
      "longest_streak": longest_streak,
      "summary": (summary as SummaryModel?)?.toJson(),
      "total_days": total_days,
      "weeks": weeks != null
          ? weeks!.map((e) => (e as WeekModel).toJson()).toList()
          : null,
      "year": year,
    };
  }
}
