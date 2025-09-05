import 'package:lissan_ai/features/practice_speaking/domain/entities/practice_session_start.dart';

class PracticeSessionStartModel extends PracticeSessionStart {
  PracticeSessionStartModel({
    required super.sessionId,
    required super.questionNumber,
  });

  factory PracticeSessionStartModel.fromJson(Map<String, dynamic> json) {
    return PracticeSessionStartModel(
      sessionId: json['session_id'] as String,
      questionNumber: json['question_number'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'question_number': questionNumber,
    };
  }
}
