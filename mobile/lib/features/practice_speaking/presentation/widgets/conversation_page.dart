import 'package:flutter/material.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/widgets/record_free_speech_audio.dart'; // import your file

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});
  final String _statusText = 'Tap to Speak';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Text(
          _statusText,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 64),
        SizedBox(
          width: 150,
          height: 150,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecordFreeSpeechAudio(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: Colors.blue,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.mic, size: 60), Text('Start')],
            ),
          ),
        ),
        const SizedBox(height: 96),
      ],
    );
  }
}
