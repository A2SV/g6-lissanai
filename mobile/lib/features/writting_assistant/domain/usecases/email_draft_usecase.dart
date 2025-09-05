import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/email_draft.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/email_repository.dart';

class EmailDraftUsecase {
  final EmailRepository repository;

  EmailDraftUsecase({required this.repository});

  Future<Either<Failure, EmailDraft>> call({
    required String amharicPrompt,
    required String tone,
    required String type,
  }) {
    return repository.getDraftedEmail(amharicPrompt, tone, type);
  }
}
