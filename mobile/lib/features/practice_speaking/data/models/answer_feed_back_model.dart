import 'package:lissan_ai/features/practice_speaking/domain/entities/answer_feed_back.dart';

class FeedbackPointModel extends FeedbackPoint {
  FeedbackPointModel({
    required super.type,
    required super.focusPhrase,
    required super.suggestion,
  });

  factory FeedbackPointModel.fromJson(Map<String, dynamic> json) {
    return FeedbackPointModel(
      type: json['type'] as String,
      focusPhrase: json['focus_phrase'] as String,
      suggestion: json['suggestion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'focus_phrase': focusPhrase,
      'suggestion': suggestion,
    };
  }
}

class AnswerFeedbackModel extends AnswerFeedback {
  AnswerFeedbackModel({
    required super.overallSummary,
    required super.feedbackPoints,
    required super.scorePercentage,
  });

  factory AnswerFeedbackModel.fromJson(Map<String, dynamic> json) {
    return AnswerFeedbackModel(
      overallSummary: json['overall_summary'] as String,
      feedbackPoints: (json['feedback_points'] as List)
          .map((e) => FeedbackPointModel.fromJson(e))
          .toList(),
      scorePercentage: json['score_percentage'] as int?,
    );
    
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_summary': overallSummary,
      'feedback_points':
          feedbackPoints.map((e) => (e as FeedbackPointModel).toJson()).toList(),
    };
  }
}
