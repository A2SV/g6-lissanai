abstract class GrammarEvent {}

class CheckGrammarEvent extends GrammarEvent {
  final String englishText;

  CheckGrammarEvent({required this.englishText});
}


class GetSentenceEvent extends GrammarEvent {}

class SendPronunciationEvent extends GrammarEvent {
  final String targetText;
  final String audioFilePath;

  SendPronunciationEvent({
    required this.targetText,
    required this.audioFilePath,
  });
}
