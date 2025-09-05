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
            isListening: state.isListening,
            recognizedText: state.recognizedText.isEmpty
                ? 'Press the mic to start speaking...'
                : state.recognizedText,
            onPressed: () {
              if (state.isListening) {
                bloc.add(StopListeningEvent());
                CustomPopupDemo(message: state.recognizedText, onNext: onNext).showCustomPopup(context);

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

class RecordButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isListening;
  final String recognizedText;

  const RecordButton({
    super.key,
    required this.onPressed,
    required this.isListening,
    required this.recognizedText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4EC3FD), width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: isListening ? const Color.fromARGB(255, 167, 38, 88) : const Color(0xFF112D4F),
              shadowColor: isListening ? const Color.fromARGB(255, 176, 36, 68) : const Color(0xFF112D4F),
              elevation: 8,
            ),
            onPressed: onPressed,
            child: Column(
              children: [
                Icon(
                  isListening ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                  size: 30,
                ),
                Text(
                  isListening ? 'Recording' : 'Start',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isListening ? 'Listening... 🎤' : 'Tap mic to start recording',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(

            height: 50,
            child: SingleChildScrollView(
              child: Text(
                recognizedText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          )
        ],
      ),
    );
  }
}
