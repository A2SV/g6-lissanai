import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/answer_feed_back.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/interview_question.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/practice_session_result.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/practice_session_start.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/user_answer.dart';

abstract class PracticeSpeakingRepository {
  Future<Either<Failure, InterviewQuestion>> getInterviewQuestion(String sessionId);
  Future<Either<Failure, PracticeSessionStart>> startPracticeSession(String type);
  Future<Either<Failure, PracticeSessionResult>> endPracticeSession(String sessionId);
  Future<Either<Failure, AnswerFeedback>> submitAndGetAnswer(UserAnswer answer);

}
