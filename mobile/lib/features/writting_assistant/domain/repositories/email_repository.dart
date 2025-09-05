import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/email_draft.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/email_improve.dart';

abstract class EmailRepository {
  Future<Either<Failure, EmailDraft>> getDraftedEmail(
    String amharicPrompt,
    String tone,
    String type,
  );
  Future<Either<Failure, EmailImprove>> getImprovedEmail(
    String userEmail,
    String tone,
    String type,
  );
}
