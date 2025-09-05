import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/exceptions.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/data/datasources/sentence_remote_data_source.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/sentence.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/sentence_repository.dart';

class SentenceRepositoryImpl implements SentenceRepository {
  final SentenceRemoteDataSource remoteDataSource;

  SentenceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Sentence>> getSentence() async {
    try {
      final remoteSentence = await remoteDataSource.getSentence();
      return Right(remoteSentence);
    } on ServerException {
      return const Left(ServerFailure(message: 'Failed to load sentence'));
    }
  }
}
