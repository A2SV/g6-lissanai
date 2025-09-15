import 'package:flutter/material.dart';
import 'package:lissan_ai/features/auth/presentation/pages/auth_wrapper_page.dart';
import 'package:lissan_ai/features/auth/presentation/pages/dashboard_page.dart';
import 'package:lissan_ai/features/auth/presentation/pages/navigation_page.dart';
import 'package:lissan_ai/features/auth/presentation/pages/onboarding_page.dart';
import 'package:lissan_ai/features/auth/presentation/pages/profile_page.dart';
import 'package:lissan_ai/features/auth/presentation/pages/signin_page.dart';
import 'package:lissan_ai/features/auth/presentation/pages/signup_page.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/pages/email_tab_view.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/pages/grammar_tab_view.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/pages/pronounciation_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const AuthWrapperPage(),
        '/sign-in': (context) => const SignInPage(),
        '/sign-up': (context) => const SignUpPage(),
        '/dashboard': (context) => const Dashboard(),
        '/navigation': (context) => const NavigationPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/email-draft': (context) => const EmailTabView(),
        '/check-grammar': (context) => const GrammarTabView(),
        '/user-profile': (context) => const UserProfilePage(),
        '/pronuncation': (context) => const PronounciationPage(),
      },
      initialRoute: '/',
    );
  }
}
