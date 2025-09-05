import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lissan_ai/core/utils/constants/auth_constants.dart';
import 'package:lissan_ai/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<int?> getExpiryTime();
  Future<void> deleteTokens();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiryTime,
  });

  // ----------------- User caching -----------------
  Future<void> saveCachedUser(Map<String, dynamic> userJson);
  Future<Map<String, dynamic>?> getCachedUser();
  Future<void> deleteCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.storage,
  });

  // ----------------- Token methods -----------------
  @override
  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: AuthConstants.accessToken);
    } catch (e) {
      throw CacheException(message: 'Failed to read access token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await storage.read(key: AuthConstants.refreshToken);
    } catch (e) {
      throw CacheException(message: 'Failed to read refresh token: $e');
    }
  }

  @override
  Future<int?> getExpiryTime() async {
    try {
      final expiryStr = await storage.read(key: AuthConstants.expiryTime);
      return expiryStr != null ? int.tryParse(expiryStr) : null;
    } catch (e) {
      throw CacheException(message: 'Failed to read expiry time: $e');
    }
  }

  @override
  Future<void> deleteTokens() async {
    try {
      await storage.delete(key: AuthConstants.accessToken);
      await storage.delete(key: AuthConstants.refreshToken);
      await storage.delete(key: AuthConstants.expiryTime);
    } catch (e) {
      throw CacheException(message: 'Failed to delete tokens: $e');
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiryTime,
  }) async {
    try {
      await storage.write(key: AuthConstants.accessToken, value: accessToken);
      await storage.write(key: AuthConstants.refreshToken, value: refreshToken);
      await storage.write(
        key: AuthConstants.expiryTime,
        value: expiryTime.toString(),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save tokens: $e');
    }
  }

  // ----------------- User caching methods -----------------
  @override
  Future<void> saveCachedUser(Map<String, dynamic> userJson) async {
    try {
      final jsonString = jsonEncode(userJson);
      await sharedPreferences.setString(AuthConstants.cachedUser, jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to save cached user: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(AuthConstants.cachedUser);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user: $e');
    }
  }

  @override
  Future<void> deleteCachedUser() async {
    try {
      await sharedPreferences.remove(AuthConstants.cachedUser);
    } catch (e) {
      throw CacheException(message: 'Failed to delete cached user: $e');
    }
  }
}
