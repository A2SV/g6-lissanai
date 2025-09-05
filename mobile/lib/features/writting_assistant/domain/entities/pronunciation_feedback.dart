class PronunciationFeedback {
  final String fullFeedbackSummary;
  final List<String> mispronouncedWords;
  final int overallAccuracyScore;

  PronunciationFeedback({
    required this.fullFeedbackSummary,
    required this.mispronouncedWords,
    required this.overallAccuracyScore,
  });
}
