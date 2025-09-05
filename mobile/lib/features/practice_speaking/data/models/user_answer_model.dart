import 'package:lissan_ai/features/practice_speaking/domain/entities/user_answer.dart';

class UserAnswerModel extends UserAnswer {
  UserAnswerModel({
    required super.sessionId,
    required super.transcript,
  });

  factory UserAnswerModel.fromJson(Map<String, dynamic>json){
    return UserAnswerModel(
      sessionId: json['sessionId'],
      transcript: json['transcript']
      
    );

  }
  Map<String, dynamic> toJson(){
    return {'sessionId':sessionId, 'transcript':transcript};
  }
}
