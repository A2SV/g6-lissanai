import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:lissan_ai/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:lissan_ai/features/auth/presentation/widgets/custom_button.dart';
import 'package:lissan_ai/features/auth/presentation/widgets/gradient_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool termsAccepted = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String? confirmPasswordError;

  @override
  void initState() {
    super.initState();
    confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validateConfirmPassword() {
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    setState(() {
      if (confirm.isNotEmpty && confirm != password) {
        confirmPasswordError = 'Passwords do not match';
      } else {
        confirmPasswordError = null;
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorBottomSheet(BuildContext context, String message) {
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
              'Signup Failed',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is AuthenticatedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(
                    child: Text(
                      'Signup Successful',
                      style: TextStyle(color: Colors.greenAccent),
                    ),
                  ),
                ),
              );
              Navigator.pushReplacementNamed(context, '/sign-in');
            } else if (authState is AuthErrorState) {
              _showErrorBottomSheet(context, authState.message);
            }
          },
          builder: (context, authState) {
            final isLoading = authState is AuthLoadingState;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Create Account',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF08B129),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'join 100+ learners already winning',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFC9C9C9),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: nameController,
                            title: 'Full Name',
                            icon: Icons.person,
                            hintText: 'Your Full Name',
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: emailController,
                            title: 'Email Address 📧',
                            icon: Icons.email,
                            hintText: 'your.email@example.com',
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: passwordController,
                            title: 'Password 🔐',
                            icon: Icons.lock,
                            hintText: 'Create a strong password',
                            obscure: !isPasswordVisible,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: confirmPasswordController,
                            title: 'Confirm Password ✅',
                            icon: Icons.lock,
                            hintText: 'Confirm your password',
                            obscure: !isConfirmPasswordVisible,
                            enabled: !isLoading,
                          ),
                          if (confirmPasswordError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 5, left: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  confirmPasswordError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: termsAccepted,
                          activeColor: const Color(0xFF112D4F),
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    termsAccepted = value ?? false;
                                  });
                                },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: const TextStyle(
                                    color: Color(0xFF08B129),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Navigator.pushNamed(context, '/terms'); // or launch URL
                                    },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    color: Color(0xFF08B129),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Navigator.pushNamed(context, '/privacy'); // or launch URL
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    GradientButton(
                      text: 'Create Account',
                      isLoading: isLoading,
                      onPressed: () {
                        if (!termsAccepted) {
                          _showErrorBottomSheet(
                            context,
                            'You must accept the Terms and Privacy Policy',
                          );
                          return;
                        }
                        if (formKey.currentState!.validate() && confirmPasswordError == null) {
                          context.read<AuthBloc>().add(
                            SignUpEvent(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 15),
                    const OrDivider(text: 'OR'),
                    const SizedBox(height: 15),
                    CustomButton(
                      onPressed: (){},
                      text: 'Continue With Google',
                      borderColor: const Color(0xFF92FFB3),
                      textColor: const Color(0xFF000000),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/sign-in'),
                          child: Text(
                            'Sign in👋',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF08B129),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
