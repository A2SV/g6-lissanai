import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/saved_email_repository.dart';

class ClearAllEmailsUsecase {
  final SavedEmailRepository repository;

  ClearAllEmailsUsecase({required this.repository});

  Future<Either<Failure, void>> call() async {
    return await repository.clearAllEmails();
  }
}
