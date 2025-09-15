import 'package:lissan_ai/features/auth/domain/entities/activity_breakdown.dart';

class ActivityBreakDownModel extends ActivityBreakDown {
  ActivityBreakDownModel({
    int? additionalProp1,
    int? additionalProp2,
    int? additionalProp3,
  }) : super(
         additionalProp1: additionalProp1,
         additionalProp2: additionalProp2,
         additionalProp3: additionalProp3,
       );

  factory ActivityBreakDownModel.fromJson(Map<String, dynamic> json) {
    return ActivityBreakDownModel(
      additionalProp1: json['additionalProp1'],
      additionalProp2: json['additionalProp2'],
      additionalProp3: json['additionalProp3'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'additionalProp1': additionalProp1,
      'additionalProp2': additionalProp2,
      'additionalProp3': additionalProp3,
    };
  }
}
