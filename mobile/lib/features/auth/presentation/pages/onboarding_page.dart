import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lissan_ai/features/auth/presentation/widgets/onboarding_step.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    const OnboardingStep(
      title: 'The Most Efficient Way to Learn Professional English',
      subtitle:
          'Master English communication with an AI-powered coach designed specifically for Ethiopian professionals seeking global opportunities.',
      image: 'assets/images/avatar.png',
      smallTitle: 'Meet Your AI English Coach',
      description:
          'I\'m here to help you master English for global opportunities',
    ),

    const OnboardingStep(
      title: 'Learn at Your Own Pace',
      subtitle:
          'Practice English anytime, anywhere with personalized exercises and AI feedback to improve your skills efficiently.',
      image: 'assets/images/avatar.png',
      smallTitle: 'Your Personal English Coach',
      description:
          'Receive real-time guidance and tips to boost your communication confidence.',
    ),

    const OnboardingStep(
      title: 'Perfect Your Writing Skills',
      subtitle:
          'Draft emails, check grammar, and write confidently with AI-assisted writing tools.',
      image: 'assets/images/avatar.png',
      smallTitle: 'Email Drafting & Grammar Checking',
      description:
          'Compose professional emails and documents effortlessly with AI suggestions.',
    ),

    const OnboardingStep(
      title: 'Prepare for Job Interviews',
      subtitle:
          'Practice mock interviews and get real-time feedback to improve your speaking and confidence.',
      image: 'assets/images/avatar.png',
      smallTitle: 'Mock Interviews',
      description:
          'Simulate real interview scenarios and get AI guidance to answer like a pro.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _pages[index];
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage != _pages.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        _controller.jumpToPage(_pages.length - 1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF112D4F),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 60),

                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        Navigator.pushReplacementNamed(context, '/sign-in');
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF112D4F),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get started'
                            : 'Next',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
