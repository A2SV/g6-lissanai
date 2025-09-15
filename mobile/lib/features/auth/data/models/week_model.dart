import 'package:lissan_ai/features/auth/domain/entities/week.dart';
import 'package:lissan_ai/features/auth/domain/entities/day.dart';
import 'package:lissan_ai/features/auth/data/models/day_model.dart';

class WeekModel extends Week {
  WeekModel({List<Day>? days}) : super(days: days);

  factory WeekModel.fromJson(Map<String, dynamic> json) {
    return WeekModel(
      days: json['days'] != null
          ? (json['days'] as List).map((e) => DayModel.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "days": days != null
          ? days!.map((e) => (e as DayModel).toJson()).toList()
          : null,
    };
  }
}
