import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/exceptions.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/core/network/network_info.dart';
import 'package:lissan_ai/features/practice_speaking/data/datasources/practice_speaking_remote_data_source.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/answer_feed_back.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/interview_question.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/practice_session_result.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/practice_session_start.dart';
import 'package:lissan_ai/features/practice_speaking/domain/entities/user_answer.dart';
import 'package:lissan_ai/features/practice_speaking/domain/repositories/practice_speaking_repository.dart';

class PracticeSpeakingRepositoriesImpl implements PracticeSpeakingRepository {
  final NetworkInfo networkInfo;
  final PracticeSpeakingRemoteDataSource remoteDataSource;
  PracticeSpeakingRepositoriesImpl({
    required this.networkInfo,
    required this.remoteDataSource,
  });
  Future<Either<Failure, T>> _execute<T>(Future<T> Function() action) async {
  try {
    final result = await action();
    return Right(result);
  } on BadRequestException catch (e) {
    return Left(ValidationFailure(message: e.message));
  } on UnAuthorizedException catch (e) {
    return Left(UnauthorizedFailure(message: e.message));
  } on ConflictException catch (e) {
    return Left(ConflictFailure(message: e.message));
  } on NotFoundException catch (e) {
    return Left(NotFoundFailure(message: e.message));
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  } catch (_) {
    return const Left(ServerFailure(message: 'Unexpected server error'));
  }
}

  @override
  Future<Either<Failure, InterviewQuestion>> getInterviewQuestion(
    String sessionId,
  ) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    return _execute(() => remoteDataSource.getInterviewQuestion(sessionId));
  }

  @override
  Future<Either<Failure, PracticeSessionResult>> endPracticeSession(
    String sessionId,
  ) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    return _execute(() => remoteDataSource.endPracticeSession(sessionId));
  }

  @override
  Future<Either<Failure, PracticeSessionStart>> startPracticeSession(
    String type,
  ) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    return _execute(() => remoteDataSource.startPracticeSession(type));
  }

  @override
  Future<Either<Failure, AnswerFeedback>> submitAndGetAnswer(
    UserAnswer answer,
  ) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    return _execute(() => remoteDataSource.answerAndGetFeedback(answer));
  }

    

}
