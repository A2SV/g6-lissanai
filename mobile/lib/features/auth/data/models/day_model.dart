import 'package:lissan_ai/features/auth/domain/entities/day.dart';

class DayModel extends Day {
  DayModel({
    int? activity_count,
    List<String>? activity_types,
    String? date,
    bool? has_activity,
  }) : super(
         activity_count: activity_count,
         activity_types: activity_types,
         date: date,
         has_activity: has_activity,
       );

  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      activity_count: json['activity_count'],
      activity_types: json['activity_types'] != null
          ? List<String>.from(json['activity_types'])
          : null,
      date: json['date'],
      has_activity: json['has_activity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "activity_count": activity_count,
      "activity_types": activity_types,
      "date": date,
      "has_activity": has_activity,
    };
  }
}
