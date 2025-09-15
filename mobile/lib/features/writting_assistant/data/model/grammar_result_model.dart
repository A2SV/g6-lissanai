import 'package:lissan_ai/features/writting_assistant/data/model/correction_model.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/grammar_result.dart';

class GrammarResultModel extends GrammarResult {
  GrammarResultModel({
    required super.correctedText,
    required super.corrections,
  });

  factory GrammarResultModel.fromJson(Map<String, dynamic> json) {
    return GrammarResultModel(
      correctedText: json['corrected_text'] ?? '',
      corrections: (json['corrections'] as List? ?? [])
          .map((c) => CorrectionModel.fromJson(c))
          .toList(),
    );
  }
}
