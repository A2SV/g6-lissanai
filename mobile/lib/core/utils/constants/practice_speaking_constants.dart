class PracticeSpeakingConstants {
  static String baseUrl = 'https://lissan-ai-backend-dev.onrender.com/api/v1';
  static String startSession = '$baseUrl/interview/start';
  static String getQuestion(String sessionId) => '$baseUrl/interview/question?session_id=$sessionId';
  static String submitAnswer = '$baseUrl/interview/answer';
  static String endSession(String sessionId) => '$baseUrl/interview/$sessionId/end';
  
  static String? userToken;
}
