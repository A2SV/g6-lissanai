import 'package:lissan_ai/features/writting_assistant/domain/entities/correction.dart';
import 'explanation_model.dart';

class CorrectionModel extends Correction {
  CorrectionModel({
    required super.originalPhrase,
    required super.correctedPhrase,
    required super.explanation,
  });

  factory CorrectionModel.fromJson(Map<String, dynamic> json) {
    return CorrectionModel(
      originalPhrase: json['original_phrase'] ?? '',
      correctedPhrase: json['corrected_phrase'] ?? '',
      explanation: ExplanationModel.fromJson(json['explanation'] ?? {}),
    );
  }
}
