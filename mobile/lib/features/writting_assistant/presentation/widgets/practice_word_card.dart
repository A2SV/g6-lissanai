import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PracticeWordCard extends StatelessWidget {
  const PracticeWordCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(239, 246, 255, 1),
            Color.fromRGBO(240, 253, 244, 1),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF112D4F)),
                  const SizedBox(width: 5),
                  Text(
                    'Practice Word',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF112D4F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Vowel Sounds',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color.fromRGBO(71, 99, 133, 1),
                ),
              ),
            ],
          ),

          // Right side
          Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/avatar.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.volume_down, size: 14, color: Color(0xFF757575)),
                  const SizedBox(width: 4),
                  Text(
                    'Listen carefully',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
