import 'package:lissan_ai/features/writting_assistant/domain/entities/correction.dart';

class GrammarResult {
  final String correctedText;
  final List<Correction> corrections;

  GrammarResult({required this.correctedText, required this.corrections});
}
