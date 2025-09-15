import 'package:lissan_ai/features/writting_assistant/domain/entities/explanation.dart';

class ExplanationModel extends Explanation {
  ExplanationModel({required super.english, required super.amharic});

  factory ExplanationModel.fromJson(Map<String, dynamic> json) {
    return ExplanationModel(
      english: json['english'] ?? '',
      amharic: json['amharic'] ?? '',
    );
  }
}
