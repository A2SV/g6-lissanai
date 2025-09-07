import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/save_email_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/get_saved_emails_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/delete_saved_email_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/clear_all_emails_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/saved_email_event.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/saved_email_state.dart';

class SavedEmailBloc extends Bloc<SavedEmailEvent, SavedEmailState> {
  final SaveEmailUsecase saveEmailUsecase;
  final GetSavedEmailsUsecase getSavedEmailsUsecase;
  final DeleteSavedEmailUsecase deleteSavedEmailUsecase;
  final ClearAllEmailsUsecase clearAllEmailsUsecase;

  SavedEmailBloc({
    required this.saveEmailUsecase,
    required this.getSavedEmailsUsecase,
    required this.deleteSavedEmailUsecase,
    required this.clearAllEmailsUsecase,
  }) : super(SavedEmailInitial()) {
    on<SaveEmailEvent>(_onSaveEmail);
    on<LoadSavedEmailsEvent>(_onLoadSavedEmails);
    on<DeleteSavedEmailEvent>(_onDeleteSavedEmail);
    on<ClearAllEmailsEvent>(_onClearAllEmails);
  }

  void _onSaveEmail(SaveEmailEvent event, Emitter<SavedEmailState> emit) async {
    emit(SavedEmailLoading());

    final result = await saveEmailUsecase(event.email);
    result.fold(
      (failure) => emit(SavedEmailError(message: failure.message)),
      (success) => emit(EmailSaved()),
    );
  }

  void _onLoadSavedEmails(
    LoadSavedEmailsEvent event,
    Emitter<SavedEmailState> emit,
  ) async {
    emit(SavedEmailLoading());

    final result = await getSavedEmailsUsecase();
    result.fold(
      (failure) => emit(SavedEmailError(message: failure.message)),
      (emails) => emit(SavedEmailsLoaded(emails: emails)),
    );
  }

  void _onDeleteSavedEmail(
    DeleteSavedEmailEvent event,
    Emitter<SavedEmailState> emit,
  ) async {
    emit(SavedEmailLoading());

    final result = await deleteSavedEmailUsecase(event.id);
    result.fold(
      (failure) => emit(SavedEmailError(message: failure.message)),
      (success) => emit(SavedEmailDeleted()),
    );
  }

  void _onClearAllEmails(
    ClearAllEmailsEvent event,
    Emitter<SavedEmailState> emit,
  ) async {
    emit(SavedEmailLoading());

    final result = await clearAllEmailsUsecase();
    result.fold(
      (failure) => emit(SavedEmailError(message: failure.message)),
      (success) => emit(AllEmailsCleared()),
    );
  }
}
