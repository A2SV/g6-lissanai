import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lissan_ai/core/network/bloc/connectivity_bloc.dart';
import 'package:lissan_ai/core/network/network_info.dart';
import 'package:lissan_ai/core/utils/helper/api_client_helper.dart';
import 'package:lissan_ai/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:lissan_ai/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lissan_ai/features/auth/data/datasources/streak_remote_data_source.dart';
import 'package:lissan_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lissan_ai/features/auth/data/repositories/streak_repository_impl.dart';
import 'package:lissan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:lissan_ai/features/auth/domain/repositories/streak_repository.dart';
import 'package:lissan_ai/features/auth/domain/usecases/freeze_streak_usecase.dart';
import 'package:lissan_ai/features/auth/domain/usecases/get_activity_calendar_usecase.dart';
import 'package:lissan_ai/features/auth/domain/usecases/get_streak_info_usecase.dart';
import 'package:lissan_ai/features/auth/domain/usecases/get_token_usecase.dart';
import 'package:lissan_ai/features/auth/domain/usecases/get_user_usecase.dart';
import 'package:lissan_ai/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:lissan_ai/features/auth/domain/usecases/sign_in_with_token_usecase.dart';
import 'package:lissan_ai/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:lissan_ai/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/streak_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/data/datasources/email_remote_data_source.dart';
import 'package:lissan_ai/features/writting_assistant/data/datasources/grammar_remote_data_sources.dart';
import 'package:lissan_ai/features/writting_assistant/data/datasources/pronunciation_remote_data_source.dart';
import 'package:lissan_ai/features/writting_assistant/data/datasources/sentence_remote_data_source.dart';
import 'package:lissan_ai/features/writting_assistant/data/repositories/email_repository_impl.dart';
import 'package:lissan_ai/features/writting_assistant/data/repositories/grammar_repository_impl.dart';
import 'package:lissan_ai/features/writting_assistant/data/repositories/pronunciation_repository_impl.dart';
import 'package:lissan_ai/features/writting_assistant/data/repositories/sentence_repository_impl.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/email_repository.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/grammar_repository.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/pronunciation_repository.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/sentence_repository.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/check_grammar_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/email_draft_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/email_improve_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/get_sentence_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/send_pronunciation_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lissan_ai/features/practice_speaking/data/datasources/practice_speaking_remote_data_source.dart';
import 'package:lissan_ai/features/practice_speaking/data/repositories/practice_speaking_repositories_impl.dart';
import 'package:lissan_ai/features/practice_speaking/data/services/speech_to_text_service.dart';
import 'package:lissan_ai/features/practice_speaking/domain/repositories/practice_speaking_repository.dart';
import 'package:lissan_ai/features/practice_speaking/domain/usecases/end_pracice_session_usecase.dart';
import 'package:lissan_ai/features/practice_speaking/domain/usecases/get_interview_questions_usecase.dart';
import 'package:lissan_ai/features/practice_speaking/domain/usecases/recognize_speech.dart';
import 'package:lissan_ai/features/practice_speaking/domain/usecases/start_practice_session_usecase.dart';
import 'package:lissan_ai/features/practice_speaking/domain/usecases/submit_answer_and_get_feedback_usecase.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/bloc/practice_speaking_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/data/datasources/saved_email_local_data_source.dart';
import 'package:lissan_ai/features/writting_assistant/data/repositories/saved_email_repository_impl.dart';
import 'package:lissan_ai/features/writting_assistant/domain/repositories/saved_email_repository.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/save_email_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/get_saved_emails_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/delete_saved_email_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/domain/usecases/clear_all_emails_usecase.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/saved_email_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  // ----------------------
  // Core / external deps
  // ----------------------
  getIt.registerLazySingleton(() => const FlutterSecureStorage());

  // You can just use the default client unless you need custom SgetIt handling
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Using only the Plus checker (does both checking + listening)
  getIt.registerLazySingleton(() => InternetConnection());

  final sharedPreferences = await SharedPreferences.getInstance();

  // register the resolved object
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  // ----------------------
  // ConnectivityBloc
  // ----------------------
  getIt.registerFactory(
    () => ConnectivityBloc(connection: getIt<InternetConnection>()),
  );

  // ----------------------
  // Auth data sources
  // ----------------------
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      storage: getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // ----------------------
  // Network info
  // ----------------------
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connection: getIt<InternetConnection>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: getIt(), localDataSource: getIt()),
  );
  // ----------------------
  // Auth repository (registered as interface, not impl)
  // ----------------------
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // ----------------------
  // Auth usecases
  // ----------------------
  getIt.registerFactory(
    () => SignUpUsecase(repository: getIt<AuthRepository>()),
  );
  getIt.registerFactory(
    () => SignInUsecase(repository: getIt<AuthRepository>()),
  );
  getIt.registerFactory(
    () => SignOutUsecase(repository: getIt<AuthRepository>()),
  );
  getIt.registerFactory(
    () => SignInWithTokenUsecase(repository: getIt<AuthRepository>()),
  );
  getIt.registerFactory(
    () => GetTokenUsecase(repository: getIt<AuthRepository>()),
  );
  getIt.registerFactory(
    () => GetUserUsecase(repository: getIt<AuthRepository>()),
  );

  // ----------------------
  // Auth bloc
  // ----------------------
  getIt.registerFactory(
    () => AuthBloc(
      signInUsecase: getIt<SignInUsecase>(),
      signOutUsecase: getIt<SignOutUsecase>(),
      signUpUsecase: getIt<SignUpUsecase>(),
      getTokenUsecase: getIt<GetTokenUsecase>(),
      signInWithTokenUsecase: getIt<SignInWithTokenUsecase>(),
      getUserUsecase: getIt<GetUserUsecase>(),
    ),
  );

  // ----------------------
  //  Writting feature
  // ----------------------

  // Remote Data Sources
  getIt.registerLazySingleton<EmailRemoteDataSource>(
    () => EmailRemoteDataSourceImpl(client: getIt()),
  );

  getIt.registerLazySingleton<GrammarRemoteDataSources>(
    () => GrammarRemoteDataSourcesImpl(
      storage: getIt<FlutterSecureStorage>(),
      client: getIt<http.Client>(),
    ),
  );

  getIt.registerLazySingleton<SentenceRemoteDataSource>(
    () => SentenceRemoteDataSourceImpl(client: getIt()),
  );
  getIt.registerLazySingleton<PronunciationRemoteDataSource>(
    () => PronunciationRemoteDataSourceImpl(client: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<EmailRepository>(
    () => EmailRepositoryImpl(
      remoteDataSource: getIt<EmailRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<GrammarRepository>(
    () => GrammarRepositoryImpl(
      remoteDataSources: getIt<GrammarRemoteDataSources>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<SentenceRepository>(
    () => SentenceRepositoryImpl(
      remoteDataSource: getIt<SentenceRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<PronunciationRepository>(
    () => PronunciationRepositoryImpl(
      remoteDataSource: getIt<PronunciationRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => EmailDraftUsecase(repository: getIt<EmailRepository>()),
  );

  getIt.registerLazySingleton(
    () => EmailImproveUsecase(repository: getIt<EmailRepository>()),
  );

  getIt.registerLazySingleton(
    () => CheckGrammarUsecase(repository: getIt<GrammarRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetSentenceUsecase(repository: getIt<SentenceRepository>()),
  );

  getIt.registerLazySingleton(
    () =>
        SendPronunciationUsecase(repository: getIt<PronunciationRepository>()),
  );

  // Bloc
  getIt.registerFactory(
    () => WrittingBloc(
      getEmailDraftUsecase: getIt<EmailDraftUsecase>(),
      checkGrammarUsecase: getIt<CheckGrammarUsecase>(),
      improveEmailUsecase: getIt<EmailImproveUsecase>(),
      saveEmailUsecase: getIt<SaveEmailUsecase>(),
      getSentenceUsecase: getIt<GetSentenceUsecase>(),
      sendPronunciationUsecase: getIt<SendPronunciationUsecase>(),
    ),
  );

  // ----------------------
  // Saved Email Dependencies
  // ----------------------
  getIt.registerLazySingleton<SavedEmailLocalDataSource>(
    () => SavedEmailLocalDataSourceImpl(sharedPreferences: getIt()),
  );

  getIt.registerLazySingleton<SavedEmailRepository>(
    () => SavedEmailRepositoryImpl(localDataSource: getIt()),
  );

  getIt.registerLazySingleton(() => SaveEmailUsecase(repository: getIt()));
  getIt.registerLazySingleton(() => GetSavedEmailsUsecase(repository: getIt()));
  getIt.registerLazySingleton(
    () => DeleteSavedEmailUsecase(repository: getIt()),
  );
  getIt.registerLazySingleton(() => ClearAllEmailsUsecase(repository: getIt()));

  // Add SavedEmailBloc registration:
  getIt.registerFactory(
    () => SavedEmailBloc(
      saveEmailUsecase: getIt(),
      getSavedEmailsUsecase: getIt(),
      deleteSavedEmailUsecase: getIt(),
      clearAllEmailsUsecase: getIt(),
    ),
  );

  // -------------------------------
  // BLoC Practice Speaking
  // -------------------------------
  getIt.registerFactory<PracticeSpeakingBloc>(
    () => PracticeSpeakingBloc(
      startPracticeSessionUsecase: getIt<StartPracticeSessionUsecase>(),
      endPracticeSessionUsecase: getIt<EndPraciceSessionUsecase>(),
      getInterviewQuestionsUsecase: getIt<GetInterviewQuestionsUsecase>(),
      submitAndGetAnswerUsecase: getIt<SubmitAnswerAndGetFeedbackUsecase>(),
      recognizeSpeech: getIt<RecognizeSpeechUsecase>(),
    ),
  );

  // -------------------------------
  // Use cases
  // -------------------------------
  getIt.registerLazySingleton<StartPracticeSessionUsecase>(
    () => StartPracticeSessionUsecase(
      repository: getIt<PracticeSpeakingRepository>(),
    ),
  );
  getIt.registerLazySingleton<EndPraciceSessionUsecase>(
    () => EndPraciceSessionUsecase(
      repository: getIt<PracticeSpeakingRepository>(),
    ),
  );
  getIt.registerLazySingleton<GetInterviewQuestionsUsecase>(
    () => GetInterviewQuestionsUsecase(
      repository: getIt<PracticeSpeakingRepository>(),
    ),
  );
  getIt.registerLazySingleton<SubmitAnswerAndGetFeedbackUsecase>(
    () => SubmitAnswerAndGetFeedbackUsecase(
      repository: getIt<PracticeSpeakingRepository>(),
    ),
  );
  getIt.registerLazySingleton<RecognizeSpeechUsecase>(
    () => RecognizeSpeechUsecase(service: getIt()),
  );

  // -------------------------------
  // Repository
  // -------------------------------
  getIt.registerLazySingleton<PracticeSpeakingRepository>(
    () => PracticeSpeakingRepositoriesImpl(
      networkInfo: getIt(),
      remoteDataSource: getIt(),
    ),
  );

  // -------------------------------
  // Services
  // -------------------------------
  getIt.registerLazySingleton<SpeechToTextService>(() => SpeechToTextService());

  getIt.registerLazySingleton(
    () => ApiClientHelper(
      client: getIt(),
      storage: getIt<FlutterSecureStorage>(),
    ),
  );
  getIt.registerLazySingleton<PracticeSpeakingRemoteDataSource>(
    () => PracticeSpeakingRemoteDataSourceImpl(apiClientHelper: getIt()),
  );

  // initialize service
  await getIt<SpeechToTextService>().init();

  // steak

  // Bloc
  getIt.registerFactory(() => StreakBloc(repository: getIt()));

  // Use cases
  getIt.registerLazySingleton(() => FreezeStreakUsecase(repository: getIt()));
  getIt.registerLazySingleton(
    () => GetActivityCalendarUsecase(repository: getIt()),
  );
  getIt.registerLazySingleton(() => GetStreakInfoUsecase(repository: getIt()));

  // Repository
  getIt.registerLazySingleton<StreakRepository>(
    () => StreakRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  // Data sources
  getIt.registerLazySingleton<StreakRemoteDataSource>(
    () => StreakRemoteDataSourceImpl(
      client: getIt(),
      authLocalDataSource: getIt(),
    ),
  );
}
