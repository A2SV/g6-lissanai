import 'dart:convert';

import 'package:lissan_ai/core/error/failure.dart';
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
  @override
  Future<PracticeSessionResult> endPracticeSession(String sessionId) async {
    final Map<String, String> body = {'session_id': sessionId};
    final response = await apiClientHelper.post(
      PracticeSpeakingConstants.endSession(sessionId),
      body,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PracticeSessionResultModel.fromJson(data);
    } else {
      throw ServerFailure(message: 'error ${response.statusCode}');
    }
  }

  @override
  Future<InterviewQuestion> getInterviewQuestion(String sessionId) async {
    final response = await apiClientHelper.get(
      PracticeSpeakingConstants.getQuestion(sessionId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      final Map<String, dynamic> data = decoded;
      return InterviewQuestionModel.fromJson(data);
    } else {
      throw ServerFailure(
        message: 'error on get interview ${response.statusCode}',
      );
    }
  }

  @override
  Future<PracticeSessionStart> startPracticeSession(String type) async {
    final Map<String, String> body = {'type': type};
    final response = await apiClientHelper.post(
      PracticeSpeakingConstants.startSession,
      body,
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      final Map<String, dynamic> data = decoded;
      return PracticeSessionStartModel.fromJson(data);
    } else {
      throw ServerFailure(
        message: 'error on start session ${response.statusCode}',
      );
    }
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
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final Map<String, dynamic> data = decoded;
      return AnswerFeedbackModel.fromJson(data);
    } else {
      throw ServerFailure(message: 'error ${response.statusCode}');
    }
  }
}
