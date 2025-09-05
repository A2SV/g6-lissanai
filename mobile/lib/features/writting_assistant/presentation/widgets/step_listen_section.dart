import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StepListenSection extends StatefulWidget {
  final String sentence;

  const StepListenSection({super.key, required this.sentence});

  @override
  State<StepListenSection> createState() => _StepListenSectionState();
}

class _StepListenSectionState extends State<StepListenSection> {
  final FlutterTts _flutterTts = FlutterTts();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    // Handle start
    _flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    // Handle completion
    _flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    // Handle error
    _flutterTts.setErrorHandler((msg) {
      setState(() {
        isPlaying = false;
      });
    });
  }

  Future<void> _speak() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(widget.sentence);
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.headset_mic_outlined,
                color: Color.fromRGBO(59, 130, 246, 1)),
            const SizedBox(width: 8),
            Text(
              'Step 1: Listen',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isPlaying ? _stop : _speak,
            icon: Icon(
              isPlaying ? Icons.stop : Icons.volume_up,
              size: 28,
              color: Colors.white,
            ),
            label: Text(
              isPlaying ? 'Stop Playing' : 'Play Sentence',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF112D4F),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
