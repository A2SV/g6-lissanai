import 'package:lissan_ai/features/auth/data/models/activity_break_down_model.dart';
import 'package:lissan_ai/features/auth/domain/entities/activity_breakdown.dart';
import 'package:lissan_ai/features/auth/domain/entities/summary.dart';

class SummaryModel extends Summary {
  SummaryModel({
    ActivityBreakDownModel? activity_breakdown,
    int? consecutive_weeks,
    int? most_active_count,
    String? most_active_day,
    int? total_activities,
  }) : super(
         activity_breakdown: activity_breakdown,
         consecutive_weeks: consecutive_weeks,
         most_active_count: most_active_count,
         most_active_day: most_active_day,
         total_activities: total_activities,
       );

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      activity_breakdown: json['activity_breakdown'] != null
          ? ActivityBreakDownModel.fromJson(json['activity_breakdown'])
          : null,
      consecutive_weeks: json['consecutive_weeks'],
      most_active_count: json['most_active_count'],
      most_active_day: json['most_active_day'],
      total_activities: json['total_activities'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "activity_breakdown": (activity_breakdown as ActivityBreakDownModel?)
          ?.toJson(),
      "consecutive_weeks": consecutive_weeks,
      "most_active_count": most_active_count,
      "most_active_day": most_active_day,
      "total_activities": total_activities,
    };
  }
}
