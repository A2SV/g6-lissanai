import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lissan_ai/app.dart';
import 'package:lissan_ai/core/network/bloc/connectivity_bloc.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/streak_bloc.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/bloc/practice_speaking_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_bloc.dart';

import 'package:lissan_ai/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ConnectivityBloc>()),
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(create: (context) => getIt<WrittingBloc>()),
        BlocProvider(create: (context) => getIt<PracticeSpeakingBloc>()),
        BlocProvider(create: (context) => getIt<StreakBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}
