import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/bloc/practice_speaking_bloc.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/widgets/feedback_popup.dart';

class CustomPopupDemo {
  final String message;
  final VoidCallback onNext;
  const CustomPopupDemo({
    required this.message,
    required this.onNext,
  });

  void showCustomPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocConsumer<PracticeSpeakingBloc, PracticeSpeakingState>(
              listener: (context, state) {
                if (state.status == BlocStatus.feedbackReceived &&
                    state.feedback != null) {
                  print('check');
                  print('check');
                  print('check');
                  print('check');
                  print(state.feedback);
                  
                  Navigator.of(context).pop();
                  
                  showDialog(
                    context: context,
                    builder: (context) {
                      return FeedbackPopup(
                        feedback: state.feedback!,
                        onNext: onNext,
                      );
                    },
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 30),
                        SizedBox(width: 8),
                        Text(
                          'Recording completed! 🎉',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.1),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.purple),
                          ),
                          icon: const Icon(Icons.refresh, color: Colors.purple),
                          label: const Text(
                            'Try Again',
                            style: TextStyle(color: Colors.purple),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: state.status == BlocStatus.loading
                              ? null 
                              : () {
                                  context.read<PracticeSpeakingBloc>().add(
                                    SubmitAnswerEvent(answer: message),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          icon: state.status == BlocStatus.loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.bolt, color: Colors.white),
                          label: Text(
                            state.status == BlocStatus.loading
                                ? 'Getting Feedback...'
                                : 'Get AI Feedback (+50 XP)',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
