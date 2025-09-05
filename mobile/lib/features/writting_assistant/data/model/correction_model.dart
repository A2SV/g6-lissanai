import 'package:lissan_ai/features/writting_assistant/domain/entities/correction.dart';

class CorrectionModel extends Correction {
  CorrectionModel({
    required super.originalPhrase,
    required super.correctedPhrase,
    required super.explanation,
  });

  factory CorrectionModel.fromJson(Map<String, dynamic> json) {
    return CorrectionModel(
      originalPhrase: json['original_phrase'],
      correctedPhrase: json['corrected_phrase'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_phrase': originalPhrase,
      'corrected_phrase': correctedPhrase,
      'explanation': explanation,
    };
  }
}
