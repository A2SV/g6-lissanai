import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/grammar_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/grammar_event.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StepPracticeSection extends StatefulWidget {
  final String sentence;
  const StepPracticeSection({super.key, required this.sentence});

  @override
  State<StepPracticeSection> createState() => _StepPracticeSectionState();
}

class _StepPracticeSectionState extends State<StepPracticeSection> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordedFilePath;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission not granted')),
      );
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: filePath);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopAndSendRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });

      if (path != null) {
        debugPrint('Recording stopped, file saved to: $path');
        // Automatically send the recording to the BLoC
        context.read<GrammarBloc>().add(
              SendPronunciationEvent(
                audioFilePath: path,
                targetText: widget.sentence,
              ),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sending for evaluation...')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording failed or was too short.')),
        );
      }
    } catch (e) {
      debugPrint('Error stopping or sending recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.mic_none, color: Color.fromRGBO(34, 197, 94, 1)),
            const SizedBox(width: 8),
            Text(
              'Step 2: Practice',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Press and Hold to Record',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10),
        
        // Hold-to-Record Button
        GestureDetector(
          onLongPressStart: (_) => _startRecording(),
          onLongPressEnd: (_) => _stopAndSendRecording(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: _isRecording ? Colors.redAccent : const Color(0xFF112D4F),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: _isRecording ? 6 : 2,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.mic,
              color: Colors.white,
              size: _isRecording ? 45 : 35,
            ),
          ),
        ),
      ],
    );
  }
}