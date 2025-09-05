import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lissan_ai/core/network/bloc/connectivity_bloc.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:lissan_ai/features/auth/presentation/pages/navigation_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            if (connectivityState is ConnectivityDisconnected) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Color(0xFF112D4F), size: 180),
                    SizedBox(height: 10),
                    Text(
                      'Please check your internet connection',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }

            return BlocConsumer<AuthBloc, AuthState>(
              listener: (context, authState) {
                if (authState is AuthErrorState) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Login Failed'),
                        ],
                      ),
                      content: Text(authState.message),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              builder: (context, authState) {
                if (authState is AuthenticatedState) {
                  return const NavigationPage();
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
                                        final email = emailController.text
                                            .trim();
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
                                    : () => Navigator.pushNamed(
                                        context,
                                        '/sign-up',
                                      ),
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
            );
          },
        ),
      ),
    );
  }
}
