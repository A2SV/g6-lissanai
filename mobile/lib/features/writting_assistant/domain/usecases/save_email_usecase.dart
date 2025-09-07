import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/saved_email.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/saved_email_repository.dart';

class SaveEmailUsecase {
  final SavedEmailRepository repository;

  SaveEmailUsecase({required this.repository});

  Future<Either<Failure, void>> call(SavedEmail email) async {
    return await repository.saveEmail(email);
  }
}