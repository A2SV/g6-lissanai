import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:lissan_ai/features/auth/presentation/widgets/custom_text_field.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
              'Login Failed',
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
            if (authState is AuthErrorState) {
              _showErrorBottomSheet(context, authState.message);
            }
          },
          builder: (context, authState) {
            if (authState is AuthenticatedState) {
              Navigator.pushReplacementNamed(context, '/navigation');
            }
            final isLoading = authState is AuthLoadingState;
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 80,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      AnimatedScale(
                        scale: isLoading ? 0.9 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF112D4F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextField(
                              controller: emailController,
                              title: 'Email Address',
                              icon: Icons.email,
                              hintText: 'Enter your email',
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 15),
                            CustomTextField(
                              controller: passwordController,
                              title: 'Password',
                              icon: Icons.lock,
                              hintText: 'Enter your password',
                              obscure: !isPasswordVisible,
                              enabled: !isLoading,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          rememberMe = value ?? false;
                                        });
                                      },
                                activeColor: const Color(0xFF112D4F),
                              ),
                              Text(
                                'Remember Me',
                                style: TextStyle(
                                  color: isLoading
                                      ? Colors.grey
                                      : const Color(0xFF112D4F),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: isLoading ? null : () {},
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: isLoading
                                    ? Colors.grey
                                    : const Color(0xFF112D4F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: isLoading ? 60 : 50,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (formKey.currentState!.validate()) {
                                    final email = emailController.text.trim();
                                    final password = passwordController.text
                                        .trim();
                                    FocusScope.of(context).unfocus();
                                    context.read<AuthBloc>().add(
                                      SignInEvent(
                                        email: email,
                                        password: password,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF112D4F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: const Color(
                              0xFF112D4F,
                            ).withOpacity(0.3),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New to LissanAI?',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: isLoading
                                ? null
                                : () =>
                                      Navigator.pushNamed(context, '/sign-up'),
                            child: Text(
                              'Create Account',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isLoading
                                    ? Colors.grey
                                    : const Color(0xFF112D4F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
