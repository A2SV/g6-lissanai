import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_event.dart';

class SubmitAudioRecord extends StatefulWidget {
  final String audioPath;
  final String senctence;

  const SubmitAudioRecord({
    super.key,
    required this.audioPath,
    required this.senctence,
  });

  @override
  State<SubmitAudioRecord> createState() => _SubmitAudioRecordState();
}

class _SubmitAudioRecordState extends State<SubmitAudioRecord> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => _isPlaying = false);
      }
    });
  }

  Future<void> _playRecording() async {
    try {
      await _audioPlayer.setFilePath(widget.audioPath);
      await _audioPlayer.play();
      setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> _sendRecording() async {
    setState(() {
      _isSending = true;
    });

    try {
      final currentState = context.read<WrittingBloc>().state;
      final sentenceText = (currentState is SentenceLoaded)
          ? currentState.sentence.text
          : widget.senctence;

      context.read<WrittingBloc>().add(
        SendPronunciationEvent(
          audioFilePath: widget.audioPath,
          targetText: sentenceText,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio sent for pronunciation evaluation'),
        ),
      );
    } catch (e) {
      debugPrint('Error sending pronunciation event: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send audio')));
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          // Play Recording Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isPlaying ? null : _playRecording,
              icon: const Icon(Icons.play_arrow, size: 28, color: Colors.white),
              label: Text(
                _isPlaying ? 'Playing...' : 'Play Recording',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
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
          const SizedBox(width: 20),

          // Send Recording Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _sendRecording,
              icon: const Icon(Icons.send, size: 24, color: Colors.white),
              label: Text(
                _isSending ? 'Sending...' : 'Send Recording',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
