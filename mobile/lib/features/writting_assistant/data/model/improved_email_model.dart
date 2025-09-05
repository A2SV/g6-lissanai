import 'package:lissan_ai/features/writting_assistant/domain/entities/email_improve.dart';

class ImprovedEmailModel extends EmailImprove {
  const ImprovedEmailModel({
    required super.subject,
    required super.improvedBody,
    super.corrections = const [],
  });

  factory ImprovedEmailModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] ?? '';
    final body = json['improvedBody'] ?? json['improved_body'] ?? json['body'] ?? '';
    
    final dynamic rawCorrections = json['corrections'];
    final List<EmailCorrection> parsedCorrections = (rawCorrections is List)
        ? rawCorrections
            .whereType<Map<String, dynamic>>()
            .map((item) => EmailCorrection(
                  original: item['original'] ?? item['original_phrase'] ?? '',
                  corrected: item['corrected'] ?? item['corrected_phrase'] ?? '',
                  explanation: item['explanation'] ?? '',
                ))
            .toList()
        : const [];

    return ImprovedEmailModel(
      subject: subject,
      improvedBody: body,
      corrections: parsedCorrections,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'improvedBody': improvedBody,
      'corrections': corrections
          .map((c) => {
                'original': c.original,
                'corrected': c.corrected,
                'explanation': c.explanation,
              })
          .toList(),
    };
  }
}