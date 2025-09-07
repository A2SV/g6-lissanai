import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/saved_email_repository.dart';

class DeleteSavedEmailUsecase {
  final SavedEmailRepository repository;

  DeleteSavedEmailUsecase({required this.repository});

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteSavedEmail(id);
  }
}