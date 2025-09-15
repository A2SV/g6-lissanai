import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/bloc/practice_speaking_bloc.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/widgets/submit_modal.dart';

class SpeechPage extends StatelessWidget {
  final VoidCallback onNext;
  const SpeechPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PracticeSpeakingBloc>();

    bloc.add(InitSpeechEvent());

    return Center(
      child: BlocBuilder<PracticeSpeakingBloc, PracticeSpeakingState>(
        builder: (context, state) {
          return RecordButton(
            onNext : onNext,
            isListening: state.isListening,
            recognizedText: state.recognizedText,
            onPressed: () {
              if (state.isListening) {
                bloc.add(StopListeningEvent());
                CustomPopupDemo(message: state.recognizedText, onNext: onNext).showCustomPopup(context);
                bloc.add(ClearRecognizedTextEvent());
              } else {
                bloc.add(StartListeningEvent());
              }
            },

          );
        },
      ),
    );
  }
}

class RecordButton extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback onNext;
  final bool isListening;
  final String recognizedText;

  const RecordButton({
    super.key,
    required this.onPressed,
    required this.isListening,
    required this.recognizedText,
    required this.onNext,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.recognizedText);
  }

  @override
  void didUpdateWidget(covariant RecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller only when recognizedText changes
    if (widget.recognizedText != controller.text) {
      controller.text = widget.recognizedText;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PracticeSpeakingBloc>();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4EC3FD), width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 🎤 Mic button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: widget.isListening
                  ? const Color.fromARGB(255, 167, 38, 88)
                  : const Color(0xFF112D4F),
            ),
            onPressed: widget.onPressed,
            child: Icon(
              widget.isListening ? Icons.mic_off : Icons.mic,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 12),

          // ✍️ Text input
          TextField(
            controller: controller,
            textDirection: TextDirection.ltr, // ✅ force left-to-right
            onChanged: (value) {
              bloc.add(UpdateRecognizedTextEvent(value));
            },
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  bloc.add(ClearRecognizedTextEvent());
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Submit Answer'),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                CustomPopupDemo(
                  message: controller.text,
                  onNext: widget.onNext,
                ).showCustomPopup(context);
                bloc.add(ClearRecognizedTextEvent());
              }
            },
          ),
        ],
      ),
    );
  }
}
