import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lissan_ai/core/error/exceptions.dart';
import 'package:lissan_ai/core/utils/constants/auth_constants.dart';
import 'package:lissan_ai/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:lissan_ai/features/auth/data/models/user_model.dart';
import 'package:lissan_ai/features/auth/domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> signUp(User user);
  Future<User> signIn(User user);
  Future<void> signOut();
  Future<User> signInWithToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource localDataSource;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.localDataSource,
  });

  @override
  Future<User> signIn(User user) async {
    try {
      final url = Uri.parse('${AuthConstants.auth}/login');
      final result = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': user.email, 'password': user.password}),
      );

      final body = jsonDecode(result.body) as Map<String, dynamic>;

      switch (result.statusCode) {
        case 200:
          final accessToken = body['access_token'];
          final refreshToken = body['refresh_token'];
          final expiresIn = body['expires_in'];

          final expiryTime = DateTime.now()
              .add(Duration(seconds: expiresIn))
              .millisecondsSinceEpoch;

          await localDataSource.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiryTime: expiryTime,
          );

          await localDataSource.saveCachedUser(body['user']);

          return UserModel.fromJson(body['user']);

        case 400:
          throw BadRequestException(message: body['error'] ?? 'Bad request');

        case 401:
          throw UnAuthorizedException(message: body['error'] ?? 'Unauthorized');

        default:
          throw ServerException(
            message: 'Unexpected error: ${result.statusCode}',
          );
      }
    } catch (e) {
      if (e is BadRequestException ||
          e is UnAuthorizedException ||
          e is ServerException) {
        rethrow;
      }
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final url = Uri.parse('${AuthConstants.auth}/logout');
      final refreshToken = await localDataSource.getRefreshToken();
      final accessToken = await localDataSource.getAccessToken();

      final result = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      final body = jsonDecode(result.body) as Map<String, dynamic>;

      if (result.statusCode == 200) {
        await localDataSource.deleteTokens();
        await localDataSource.deleteCachedUser();
      } else if (result.statusCode == 401) {
        throw UnAuthorizedException(message: body['error'] ?? 'Unauthorized');
      } else {
        throw ServerException(
          message: 'Unexpected error: ${result.statusCode}',
        );
      }
    } catch (e) {
      if (e is UnAuthorizedException || e is ServerException) {
        rethrow;
      }
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<User> signUp(User user) async {
    final url = Uri.parse('${AuthConstants.auth}/register');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': user.email,
        'name': user.name,
        'password': user.password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    switch (response.statusCode) {
      case 201:
        final accessToken = body['access_token'];
        final refreshToken = body['refresh_token'];
        final expiresIn = body['expires_in'];

        final expiryTime = DateTime.now()
            .add(Duration(seconds: expiresIn))
            .millisecondsSinceEpoch;

        await localDataSource.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiryTime: expiryTime,
        );

        await localDataSource.saveCachedUser(body['user']);

        return UserModel.fromJson(body['user']);

      case 400:
        throw BadRequestException(message: body['error'] ?? 'Bad request');

      case 409:
        throw ConflictException(
          message: body['error'] ?? 'User already exists',
        );

      default:
        throw ServerException(
          message: 'Unexpected error: ${response.statusCode}',
        );
    }
  }

  @override
  Future<User> signInWithToken() async {
    final user = await localDataSource.getCachedUser();
    if (user == null) {
      throw const CacheException(message: 'no user found');
    }
    return UserModel.fromJson(user);
  }
}
