import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lissan_ai/core/error/exceptions.dart';
import 'package:lissan_ai/core/utils/constants/practice_speaking_constants.dart';
import 'package:lissan_ai/core/utils/helper/api_client_helper.dart';
import 'package:lissan_ai/features/practice_speaking/data/models/answer_feed_back_model.dart';
import 'package:lissan_ai/features/practice_speaking/data/models/interview_question_model.dart';
import 'package:lissan_ai/features/practice_speaking/data/models/practice_session_result_model.dart';
import 'package:lissan_ai/features/practice_speaking/data/models/practice_session_start.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/answer_feed_back.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/interview_question.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/practice_session_result.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/practice_session_start.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/user_answer.dart';

abstract class PracticeSpeakingRemoteDataSource {
  Future<InterviewQuestion> getInterviewQuestion(String sessionId);
  Future<AnswerFeedback> answerAndGetFeedback(UserAnswer answer);
  Future<PracticeSessionStart> startPracticeSession(String type);
  Future<PracticeSessionResult> endPracticeSession(String sessionId);
}

class PracticeSpeakingRemoteDataSourceImpl
    implements PracticeSpeakingRemoteDataSource {
  final ApiClientHelper apiClientHelper;
  PracticeSpeakingRemoteDataSourceImpl({required this.apiClientHelper});

dynamic handleResponse(http.Response response) {
  final body = response.body.isNotEmpty
      ? jsonDecode(response.body) as Map<String, dynamic>
      : {};

  switch (response.statusCode) {
    case 200:
    case 201:
      return body;

    case 400:
      throw BadRequestException(message: body['error'] ?? 'Bad request');
    case 401:
      throw UnAuthorizedException(message: body['error'] ?? 'Unauthorized');
    case 403:
      throw UnAuthorizedException(message: body['error'] ?? 'Forbidden');
    case 404:
      throw NotFoundException(message: body['error'] ?? 'Not found');

    case 409:
      throw ConflictException(message: body['error'] ?? 'Conflict');

    case 500:
    default:
      throw ServerException(
        message: body['error'] ?? 'Unexpected error: ${response.statusCode}',
      );
  }
}

  @override
  Future<PracticeSessionResult> endPracticeSession(String sessionId) async {
    final Map<String, String> body = {'session_id': sessionId};

    final response = await apiClientHelper.post(
      PracticeSpeakingConstants.endSession(sessionId),
      body,
    );

    // ✅ Let handleResponse throw if status is not OK
    final responseBody = handleResponse(response);

    return PracticeSessionResultModel.fromJson(responseBody);
  }


  @override
  Future<InterviewQuestion> getInterviewQuestion(String sessionId) async {
    final response = await apiClientHelper.get(
      PracticeSpeakingConstants.getQuestion(sessionId),
    );
    final responseBody = handleResponse(response);
    return InterviewQuestionModel.fromJson(responseBody);
  }

  @override
  Future<PracticeSessionStart> startPracticeSession(String type) async {
    final Map<String, String> body = {'type': type};
    final response = await apiClientHelper.post(
      PracticeSpeakingConstants.startSession,
      body,
    );
    final responseBody = handleResponse(response);
    return PracticeSessionStartModel.fromJson(responseBody);
  }

  @override
  Future<AnswerFeedback> answerAndGetFeedback(UserAnswer answer) async {
    final Map<String, dynamic> body = {
      'session_id': answer.sessionId,
      'answer': answer.transcript,
    };
    final response = await apiClientHelper.post(
      PracticeSpeakingConstants.submitAnswer,
      body,
    );
   final responseBody = handleResponse(response);
    return AnswerFeedbackModel.fromJson(responseBody);
  }
}
