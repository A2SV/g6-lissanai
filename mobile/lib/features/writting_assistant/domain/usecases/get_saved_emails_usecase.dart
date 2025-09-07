import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/saved_email.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/saved_email_repository.dart';

class GetSavedEmailsUsecase {
  final SavedEmailRepository repository;

  GetSavedEmailsUsecase({required this.repository});

  Future<Either<Failure, List<SavedEmail>>> call() async {
    return await repository.getSavedEmails();
  }
}