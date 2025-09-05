import 'package:flutter/material.dart';
import 'package:lissan_ai/features/practice_speaking/data/models/answer_feed_back_model.dart';

class FeedbackPopup extends StatelessWidget {
  final AnswerFeedbackModel feedback;
  final VoidCallback onNext;
  const FeedbackPopup({
    super.key,
    required this.feedback,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final feedbackPoints = feedback.feedbackPoints;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // 80% of screen
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.feedback, color: Colors.green, size: 40),
              const SizedBox(height: 12),
              const Text(
                'AI Feedback',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                feedback.overallSummary,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              /// remove the fixed 200px height
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: feedbackPoints.length,
                itemBuilder: (context, index) {
                  final point = feedbackPoints[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        Icons.circle,
                        size: 12,
                        color: Colors.blue.shade400,
                      ),
                      title: Text(
                        '[${point.type}] - ${point.focusPhrase}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        point.suggestion,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Score: ${feedback.scorePercentage}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  onNext();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Next Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
