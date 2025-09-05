class PracticeSessionResult {
  final String sessionId;
  final int totalQuestions;
  final int completed;
  final List<dynamic> strengths;
  final List<dynamic> weaknesses;
  final int finalScore;
  final int createdAt; // you can also wrap this as DateTime

  PracticeSessionResult({
    required this.sessionId,
    required this.totalQuestions,
    required this.completed,
    required this.strengths,
    required this.weaknesses,
    required this.finalScore,
    required this.createdAt,
  });
}
