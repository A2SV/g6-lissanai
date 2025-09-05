class AuthConstants {
  static String baseUrl = 'https://lissan-ai-backend-dev.onrender.com/api/v1';
  static String auth = '$baseUrl/auth';
  static String users = '$baseUrl/users';

  // TOKEN CONSTANTS
  static const String accessToken = 'ACCESS_TOKEN';
  static const String refreshToken = 'REFRESH_TOKEN';
  static const String expiryTime = 'EXPIRY_TIME';
  // CACHED CONSTANTS

  static const String cachedUser = 'CACHED_USER';
}
