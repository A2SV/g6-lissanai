import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/exceptions.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/data/datasources/pronunciation_remote_data_source.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/pronunciation_feedback.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/pronunciation_repository.dart';

class PronunciationRepositoryImpl implements PronunciationRepository {
  final PronunciationRemoteDataSource remoteDataSource;

  PronunciationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PronunciationFeedback>> sendPronunciation(
    String sentence,
    File audioFile,
  ) async {
    try {
      final remoteResponse =
          await remoteDataSource.sendPronunciation(sentence, audioFile);
      return Right(remoteResponse);
    } on ServerException {
      return const Left(ServerFailure(message: 'Failed to send pronunciation'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
