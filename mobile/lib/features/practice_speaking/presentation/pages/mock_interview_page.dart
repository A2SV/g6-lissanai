import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/bloc/practice_speaking_bloc.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/pages/end_page.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/widgets/question_card.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/widgets/record_button.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/widgets/navigation_buttons.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/widgets/record_free_speech_audio.dart';
import 'package:shimmer/shimmer.dart';

class MockInterviewPage extends StatefulWidget {
  const MockInterviewPage({super.key});

  @override
  State<MockInterviewPage> createState() => _MockInterviewPageState();
}

class _MockInterviewPageState extends State<MockInterviewPage> {
  int _currentPage = 1;
  final int _maxPage = 5;
  late FlutterTts flutterTts;
  String selectedMode = 'mock';

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _setTtsSettings();

    context.read<PracticeSpeakingBloc>().add(
      const StartPracticeSessionEvent(type: 'interview'),
    );
  }

  Future<void> _setTtsSettings() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: BlocConsumer<PracticeSpeakingBloc, PracticeSpeakingState>(
        listenWhen: (previous, current) =>
            previous.currentQuestion != current.currentQuestion ||
            previous.status != current.status,
        listener: (context, state) {
          if (state.status == BlocStatus.sessionStarted) {
            context.read<PracticeSpeakingBloc>().add(
              const GetInterviewQuestionsEvent(),
            );
          }

          if (state.status == BlocStatus.sessionEnded &&
              state.endSessionFeedback != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EndPage(feedback: state.endSessionFeedback!),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BlocStatus.loading) {
            return _buildShimmerLoading();
          }

          if (state.status == BlocStatus.error) {
            return Center(
              child: Text(
                state.error ?? 'Something went wrong',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if ((state.status == BlocStatus.questionsLoaded ||
                  state.status == BlocStatus.questionLoading) &&
              state.currentQuestion != null) {
            final currentQuestion = state.currentQuestion!.question;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildCustomButton('Mock Interview', 'mock'),
                      const SizedBox(width: 8),
                      buildCustomButton('Free Speaking', 'free'),
                    ],
                  ),

                  if (selectedMode == 'mock')
                    _buildMockSection(context, state, currentQuestion)
                  else
                    _buildFreeSpeakingSection(context),
                ],
              ),
            );
          }

          return _buildShimmerLoading();
        },
      ),
    );
  }

  /// Mock Interview Section
  Widget _buildMockSection(
    BuildContext context,
    PracticeSpeakingState state,
    String currentQuestion,
  ) {
    return Column(
      children: [
        Text(
          '🎯 Mock Interview Practice',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDDFFEF), Color(0xFFE2EFFF)],
            ),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
          ),
          child: Text(
            'Question $_currentPage of $_maxPage. Let\'s practice this together! 💪',
          ),
        ),
        _buildProgressBar(),
        const SizedBox(height: 8),
        QuestionCard(
          status: state.status == BlocStatus.questionLoading,
          question: currentQuestion,
          onSpeak: () => _speak(currentQuestion),
        ),
        SpeechPage(onNext: () => _handleNextQuestion(context, state)),
        const SizedBox(height: 16),
        NavigationButtons(
          currentPage: _currentPage,
          maxPage: _maxPage,
          onPrevious: () {
            if (_currentPage > 1) {
              setState(() => _currentPage--);
            }
            if (state.currentQuestionIndex > 0) {
              context.read<PracticeSpeakingBloc>().add(
                MoveToPreviousQuestionEvent(),
              );
            }
          },
          onNext: () => _handleNextQuestion(context, state),
        ),
        const SizedBox(height: 8),
        const Text(
          '🔥 Keep practicing to maintain your streak!',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _handleNextQuestion(BuildContext context, PracticeSpeakingState state) {
    if (_currentPage < _maxPage + 1) {
      setState(() => _currentPage++);
    }

    if (state.currentQuestionIndex < state.questions.length - 1) {
      context.read<PracticeSpeakingBloc>().add(MoveToNextQuestionEvent());
    } else if (state.currentQuestionIndex >= 5 || _currentPage > _maxPage) {
      context.read<PracticeSpeakingBloc>().add(
        EndPracticeSessionEvent(sessionId: state.session.sessionId),
      );
    } else {
      context.read<PracticeSpeakingBloc>().add(
        const GetInterviewQuestionsEvent(),
      );
    }
  }

  Widget _buildFreeSpeakingSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          '🗣️ Free Speaking Mode',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        const RecordFreeSpeechAudio(
          websocketUrl:
              'wss://lissan-ai-backend-dev.onrender.com/api/v1/ws/conversation',
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: _currentPage / _maxPage,
              minHeight: 16,
              color: const Color(0xFF0FC753),
              backgroundColor: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Text('$_currentPage/$_maxPage'),
        ],
      ),
    );
  }

  Widget buildCustomButton(String text, String mode) {
    final isSelected = selectedMode == mode;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedMode = mode;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color(0xFF112D4F)
            : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(text),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(width: 200, height: 20, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 120,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(height: 40, color: Colors.white),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
