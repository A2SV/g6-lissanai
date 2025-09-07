import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/core/error/exceptions.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/saved_email.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/saved_email_repository.dart';
import 'package:lissan_ai/features/writting_assistant/data/datasources/saved_email_local_data_source.dart';
import 'package:lissan_ai/features/writting_assistant/data/model/saved_email_model.dart';

class SavedEmailRepositoryImpl implements SavedEmailRepository {
  final SavedEmailLocalDataSource localDataSource;

  SavedEmailRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> saveEmail(SavedEmail email) async {
    try {
      final SavedEmailModel emailModel = SavedEmailModel.fromEntity(email);
      await localDataSource.saveEmail(emailModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save email'));
    }
  }

  @override
  Future<Either<Failure, List<SavedEmail>>> getSavedEmails() async {
    try {
      final List<SavedEmailModel> emailModels = await localDataSource
          .getSavedEmails();
      final List<SavedEmail> emails = emailModels.cast<SavedEmail>();
      return Right(emails);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load saved emails'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSavedEmail(String id) async {
    try {
      await localDataSource.deleteSavedEmail(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete email'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllEmails() async {
    try {
      await localDataSource.clearAllEmails();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear all emails'));
    }
  }
}
