import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:lissan_ai/features/auth/presentation/pages/navigation_page.dart';
import 'package:lissan_ai/features/auth/presentation/pages/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lissan_ai/features/auth/presentation/pages/onboarding_page.dart';
import 'package:google_fonts/google_fonts.dart';

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

  void _showErrorBottomSheet(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 15),
              Text(
                'Authentication Error',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF112D4F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Dismiss',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstTime != null && _isFirstTime!) {
      return const OnboardingPage();
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          _showErrorBottomSheet(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is UnAuthenticatedState) {
          return const SignInPage();
        } else if (state is AuthenticatedState || state is UserInfoState) {
          return const NavigationPage();
        } else if (state is AuthLoadingState) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SpinKitDoubleBounce(color: Color(0xFF112D4F), size: 70.0),
            ),
          );
        } else {
          // default: spinner while loading unknown states
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
