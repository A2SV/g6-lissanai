import 'package:lissan_ai/features/writting_assistant/domain/entities/email_draft.dart';

class EmailDraftModel extends EmailDraft {
  const EmailDraftModel({
    required super.subject,
    required super.body,
  });

  factory EmailDraftModel.fromJson(Map<String, dynamic> json) {
    return EmailDraftModel(
      subject: json['subject'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'body': body,
    };
  }
}