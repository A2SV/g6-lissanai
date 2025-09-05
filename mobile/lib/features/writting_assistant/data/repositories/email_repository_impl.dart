import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/core/network/network_info.dart';
import 'package:lissan_ai/features/writting_assistant/data/datasources/email_remote_data_source.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/email_draft.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/email_improve.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/email_repository.dart';

class EmailRepositoryImpl implements EmailRepository {
  final EmailRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  EmailRepositoryImpl({
    required this.networkInfo,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, EmailDraft>> getDraftedEmail(
    String amharicPrompt,
    String tone,
    String type,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(
          await remoteDataSource.getDraftedEmail(amharicPrompt, tone, type),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    }
    return const Left(ServerFailure(message: 'no internet connection'));
  }

  @override
  Future<Either<Failure, EmailImprove>> getImprovedEmail(
    String userEmail,
    String tone,
    String type,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(
          await remoteDataSource.getImprovedEmail(userEmail, tone, type),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    }
    return const Left(ServerFailure(message: 'no internet connection'));
  }
}
