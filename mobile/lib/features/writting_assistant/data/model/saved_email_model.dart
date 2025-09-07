import 'package:lissan_ai/features/writting_assistant/domain/entities/saved_email.dart';

class SavedEmailModel extends SavedEmail {
  const SavedEmailModel({
    required super.id,
    required super.subject,
    required super.body,
  });

  factory SavedEmailModel.fromJson(Map<String, dynamic> json) {
    return SavedEmailModel(
      id: json['id'] as String,
      subject: json['subject'] as String,
      body: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'body': body,
    };
  }

  factory SavedEmailModel.fromEntity(SavedEmail entity) {
    return SavedEmailModel(
      id: entity.id,
      subject: entity.subject,
      body: entity.body,
    );
  }
}