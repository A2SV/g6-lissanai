import 'package:lissan_ai/features/writting_assistant/domain/entities/explanation.dart';

class Correction {
  final String originalPhrase;
  final String correctedPhrase;
  final Explanation explanation;

  Correction({
    required this.originalPhrase,
    required this.correctedPhrase,
    required this.explanation,
  });
}
