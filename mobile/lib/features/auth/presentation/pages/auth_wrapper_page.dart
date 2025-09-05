import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lissan_ai/features/auth/presentation/pages/navigation_page.dart';
import 'package:lissan_ai/features/auth/presentation/pages/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:lissan_ai/features/auth/presentation/pages/onboarding_page.dart';

class AuthWrapperPage extends StatefulWidget {
  const AuthWrapperPage({super.key});

  @override
  State<AuthWrapperPage> createState() => _AuthWrapperPageState();
}

class _AuthWrapperPageState extends State<AuthWrapperPage> {
  bool? _isFirstTime;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    context.read<AuthBloc>().add(AppStartedEvent());
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final firstTime = prefs.getBool('first_time') ?? true;
    if (firstTime) {
      await prefs.setBool('first_time', false);
    }
    setState(() {
      _isFirstTime = firstTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstTime != null && _isFirstTime!) {
      return const OnboardingPage();
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is UnAuthenticatedState) {
          return const SignInPage();
        } else if (state is AuthenticatedState) {
          return const NavigationPage();
        } else if (state is AuthErrorState) {
          return Scaffold(body: Center(child: Text(state.message)));
        } else if (state is AuthLoadingState) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SpinKitDoubleBounce(color: Color(0xFF112D4F), size: 70.0),
            ),
          );
        } else {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SpinKitDoubleBounce(color: Color(0xFF112D4F), size: 70.0),
            ),
          );
        }
      },
    );
  }
}
