import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/email_improve.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/email_repository.dart';

class EmailImproveUsecase {
  final EmailRepository repository;

  EmailImproveUsecase({required this.repository});

  Future<Either<Failure, EmailImprove>> call({
    required String userEmail,
    required String tone,
    required String type,
  }) {
    return repository.getImprovedEmail(userEmail, tone, type);
  }
}     
