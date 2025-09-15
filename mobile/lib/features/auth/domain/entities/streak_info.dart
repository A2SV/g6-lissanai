// ignore_for_file: non_constant_identifier_names

class StreakInfo {
  final bool? can_freeze;
  final int? current_streak;
  final int? days_until_loss;
  final int? freeze_count;
  final String? last_activity_date;
  final int? longest_streak;
  final int? max_freezes;
  final bool? streak_frozen;

  const StreakInfo({
    this.can_freeze,
    this.current_streak,
    this.days_until_loss,
    this.freeze_count,
    this.last_activity_date,
    this.longest_streak,
    this.max_freezes,
    this.streak_frozen,
  });
}
