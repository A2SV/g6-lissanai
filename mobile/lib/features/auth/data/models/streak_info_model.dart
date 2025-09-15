import 'package:lissan_ai/features/auth/domain/entities/streak_info.dart';

class StreakInfoModel extends StreakInfo {
  StreakInfoModel({
    bool? can_freeze,
    int? current_streak,
    int? days_until_loss,
    int? freeze_count,
    String? last_activity_date,
    int? longest_streak,
    int? max_freezes,
    bool? streak_frozen,
  }) : super(
         can_freeze: can_freeze,
         current_streak: current_streak,
         days_until_loss: days_until_loss,
         freeze_count: freeze_count,
         last_activity_date: last_activity_date,
         longest_streak: longest_streak,
         max_freezes: max_freezes,
         streak_frozen: streak_frozen,
       );

  factory StreakInfoModel.fromJson(Map<String, dynamic> json) {
    return StreakInfoModel(
      can_freeze: json['can_freeze'],
      current_streak: json['current_streak'],
      days_until_loss: json['days_until_loss'],
      freeze_count: json['freeze_count'],
      last_activity_date: json['last_activity_date'],
      longest_streak: json['longest_streak'],
      max_freezes: json['max_freezes'],
      streak_frozen: json['streak_frozen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_freeze': can_freeze,
      'current_streak': current_streak,
      'days_until_loss': days_until_loss,
      'freeze_count': freeze_count,
      'last_activity_date': last_activity_date,
      'longest_streak': longest_streak,
      'max_freezes': max_freezes,
      'streak_frozen': streak_frozen,
    };
  }
}
