import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_event.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_state.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/widgets/practice_word_card.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/widgets/sentence_display.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/widgets/step_listen_section.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/widgets/step_practice_section.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/widgets/pronunciation_feedback_section.dart';

class PronounciationPage extends StatefulWidget {
  const PronounciationPage({super.key});

  @override
  State<PronounciationPage> createState() => _PronounciationPageState();
}

class _PronounciationPageState extends State<PronounciationPage> {
  @override
  void initState() {
    super.initState();
    context.read<WrittingBloc>().add(GetSentenceEvent());
  }

  void _fetchNextSentence() {
    context.read<WrittingBloc>().add(GetSentenceEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<WrittingBloc, WrittingState>(
        listener: (context, state) {
          if (state is GrammarError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is SentenceLoading) {
            return const Center(child: SpinKitCircle(color: Colors.grey));
          } else if (state is GrammarError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Something went wrong',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchNextSentence,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          String sentence = '';
          List<String>? mispronouncedWords;

          if (state is SentenceLoaded) {
            sentence = state.sentence.text;
          } else if (state is PronunciationLoaded) {
            sentence = state.sentence;
            mispronouncedWords = state.feedback.mispronouncedWords;
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PracticeWordCard(),
                  const SizedBox(height: 24),

                  SentenceDisplay(
                    sentence: sentence,
                    mispronouncedWords: mispronouncedWords,
                  ),
                  const SizedBox(height: 24),

                  StepListenSection(sentence: sentence),
                  const SizedBox(height: 24),

                  StepPracticeSection(sentence: sentence),
                  const SizedBox(height: 24),

                  // Show pronunciation feedback
                  if (state is PronunciationLoaded)
                    PronunciationFeedbackSection(feedback: state.feedback),

                  // Show "Next Sentence" button only after feedback is loaded
                  if (state is PronunciationLoaded)
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              // ignore: prefer_single_quotes
                              "Great job! Ready for the next one?",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _fetchNextSentence,
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Next Sentence',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF112D4F),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  textStyle: const TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
