import 'package:lissan_ai/features/practice_speaking/domain/entities/practice_session_result.dart';

class PracticeSessionResultModel extends PracticeSessionResult {
  PracticeSessionResultModel({
    required super.sessionId,
    required super.totalQuestions,
    required super.completed,
    required super.strengths,
    required super.weaknesses,
    required super.finalScore,
    required super.createdAt,
  });

  factory PracticeSessionResultModel.fromJson(Map<String, dynamic> json) {
    return PracticeSessionResultModel(
      completed: json['completed'] as int,
      createdAt: json['created_at'] as int,
      finalScore: json['final_score'] as int,
      sessionId: json['session_id'] as String,
      strengths: List<String>.from(json['strengths'] ?? []),   
      totalQuestions: json['total_questions'] as int,
      weaknesses: List<String>.from(json['weaknesses'] ?? []), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'total_questions': totalQuestions,
      'completed': completed,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'final_score': finalScore,
      'created_at': createdAt,
    };
  }
}


