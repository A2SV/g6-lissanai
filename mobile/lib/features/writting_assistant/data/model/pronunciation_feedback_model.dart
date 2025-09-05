import 'package:lissan_ai/features/writting_assistant/domain/entities/pronunciation_feedback.dart';

class PronunciationFeedbackModel extends PronunciationFeedback {
  PronunciationFeedbackModel({
    required super.fullFeedbackSummary,
    required super.mispronouncedWords,
    required super.overallAccuracyScore,
  });

  factory PronunciationFeedbackModel.fromJson(Map<String, dynamic> json) {
    return PronunciationFeedbackModel(
      fullFeedbackSummary: json['full_feedback_summary'] ?? '',
      mispronouncedWords: List<String>.from(json['mispronouncedwords'] ?? []),
      overallAccuracyScore: json['overall_accuracy_score'] ?? 0,
    );
  }
}
