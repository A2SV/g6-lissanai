import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SentenceDisplay extends StatelessWidget {
  final String sentence;
  final List<String>? mispronouncedWords;

  const SentenceDisplay({
    super.key,
    required this.sentence,
    this.mispronouncedWords,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your sentence to practice:',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 22, // Increased font size
                fontWeight: FontWeight.w500,
                color: const Color(0xFF112D4F),
                height: 1.5, // Improved line spacing
              ),
              children: _buildTextSpans(),
            ),
          ),
        ),
      ],
    );
  }

  List<TextSpan> _buildTextSpans() {
    if (mispronouncedWords == null || mispronouncedWords!.isEmpty) {
      return [TextSpan(text: sentence)];
    }

    final List<TextSpan> spans = [];
    final Set<String> mispronouncedSet =
        mispronouncedWords!.map((w) => w.toLowerCase()).toSet();

    sentence.split(' ').forEach((word) {
      final cleanedWord =
          word.replaceAll(RegExp(r"[.,!?]"), "").toLowerCase();
      final isMispronounced = mispronouncedSet.contains(cleanedWord);

      spans.add(
        TextSpan(
          text: '$word ',
          style: TextStyle(
            color: isMispronounced ? Colors.red.shade700 : Colors.green.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });

    return spans;
  }
}