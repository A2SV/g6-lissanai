import 'package:lissan_ai/features/writting_assistant/domain/entities/sentence.dart';

class SentenceModel extends Sentence{
  SentenceModel({required super.id, required super.text});

  factory SentenceModel.fromJson(Map<String, dynamic> json) {
    return SentenceModel(
      id: json['id'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}

