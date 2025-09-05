import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/core/network/network_info.dart';
import 'package:lissan_ai/features/writting_assistant/data/datasources/grammar_remote_data_sources.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/grammar_result.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/grammar_repository.dart';

class GrammarRepositoryImpl implements GrammarRepository {
  final GrammarRemoteDataSources remoteDataSources;
  final NetworkInfo networkInfo;

  GrammarRepositoryImpl({
    required this.remoteDataSources,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, GrammarResult>> checkGrammar(
    String englishText,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final grammarResult = await remoteDataSources.checkGrammar(englishText);
        return Right(grammarResult);
      } catch (e) {
        return const Left(ServerFailure(message: 'Failed to check grammar'));
      }
    } else {
      return const Left(ServerFailure(message: 'No internet connection'));
    }
  }
}
