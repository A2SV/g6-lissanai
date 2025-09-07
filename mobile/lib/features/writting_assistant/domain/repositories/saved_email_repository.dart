import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/saved_email.dart';

abstract class SavedEmailRepository {
  Future<Either<Failure, void>> saveEmail(SavedEmail email);
  Future<Either<Failure, List<SavedEmail>>> getSavedEmails();
  Future<Either<Failure, void>> deleteSavedEmail(String id);
  Future<Either<Failure, void>> clearAllEmails();
}
