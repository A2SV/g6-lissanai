import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final VoidCallback onSpeak;
  final bool status;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onSpeak,
    required this.status,
  });
  

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4EC3FD), width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              _buildTag('General', Colors.grey[200], Colors.black54),
              const SizedBox(width: 8),
              _buildTag('Easy', Colors.green[100], Colors.green),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    SizedBox(width: 4),
                    Text('50XP', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onSpeak,
                icon: const Icon(Icons.volume_up, color: Colors.blue),
              ),
              const SizedBox(width: 2),
              const Text('Listen'),
            ],
          ),
          const SizedBox(height: 6),
          status ? const LinearProgressIndicator() : Text(
            question,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lissan's Tip: Keep it professional, focus on relevant experience, and be concise.",
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color? bgColor, Color? textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: textColor)),
    );
  }
}
