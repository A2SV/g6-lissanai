import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lissan_ai/core/error/exceptions.dart';
import 'package:lissan_ai/core/utils/constants/streak_constants.dart';
import 'package:lissan_ai/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:lissan_ai/features/auth/data/models/streak_calendar_model.dart';
import 'package:lissan_ai/features/auth/data/models/streak_info_model.dart';

abstract class StreakRemoteDataSource {
  Future<void> freezeStreak();
  Future<StreakCalendarModel> getActivityCalendar();
  Future<StreakInfoModel> getStreakInfo();
  Future<void> recordActivity();
}

class StreakRemoteDataSourceImpl implements StreakRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;

  StreakRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authLocalDataSource.getAccessToken();
    if (token == null) {
      throw const CacheException(message: 'No access token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<void> freezeStreak() async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('${StreakConstants.baseUrl}${StreakConstants.freeze}'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw const ServerException(message: 'Failed to freeze streak');
    }
  }

  @override
  Future<StreakCalendarModel> getActivityCalendar() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('${StreakConstants.baseUrl}${StreakConstants.calendar}'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return StreakCalendarModel.fromJson(json.decode(response.body));
    } else {
      throw const ServerException(message: 'Failed to load activity calendar');
    }
  }

  @override
  Future<StreakInfoModel> getStreakInfo() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('${StreakConstants.baseUrl}${StreakConstants.info}'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return StreakInfoModel.fromJson(json.decode(response.body));
    } else {
      throw const ServerException(message: 'Failed to load streak info');
    }
  }

  @override
  Future<void> recordActivity() async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('${StreakConstants.baseUrl}${StreakConstants.activity}'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw const ServerException(message: 'Failed to record activity');
    }
  }
}
