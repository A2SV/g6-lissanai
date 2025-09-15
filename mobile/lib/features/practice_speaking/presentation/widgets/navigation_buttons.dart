import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  final int currentPage;
  final int maxPage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool status;

  const NavigationButtons({
    super.key,
    required this.currentPage,
    required this.maxPage,
    required this.onPrevious,
    required this.onNext,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentPage > 1)
          ElevatedButton(
            onPressed: onPrevious,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                side: BorderSide(color: Color(0xFF4EC3FD), width: 0.5),
              ),
              padding: const EdgeInsets.all(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.black),
                Text('  Previous', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        const SizedBox(width: 32),
        ElevatedButton(
          onPressed:status ? null : onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF112D4F),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.all(12),
          ),
          child: status ? const Center(child: 
          SizedBox(width: 20, height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),),) : 
          Row(
            children: [
              Text(
                currentPage < maxPage ? 'Next Question  ' : 'End Session',
                style: const TextStyle(color: Colors.white),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}
