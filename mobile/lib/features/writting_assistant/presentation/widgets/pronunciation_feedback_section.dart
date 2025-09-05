import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lissan_ai/features/writting_assistant/domain/entities/pronunciation_feedback.dart';

class PronunciationFeedbackSection extends StatelessWidget {
  final PronunciationFeedback feedback;

  const PronunciationFeedbackSection({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(239, 246, 255, 1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color.fromRGBO(191, 219, 254, 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Feedback',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF112D4F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: feedback.overallAccuracyScore > 70
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: feedback.overallAccuracyScore > 70
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
                child: Text(
                  'Score: ${feedback.overallAccuracyScore}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: feedback.overallAccuracyScore > 70
                        ? Colors.green.shade900
                        : Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1.0),
          Text(
            feedback.fullFeedbackSummary,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
