import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GrammarResultShimmerPage extends StatelessWidget {
  const GrammarResultShimmerPage({super.key});

  Widget _shimmerBox({
    double width = double.infinity,
    double height = 16,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _shimmerCircle({double size = 64}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _shimmerCircle(size: 26),
                    const SizedBox(width: 8),
                    _shimmerBox(
                      width: 120,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                _shimmerBox(
                  width: 60,
                  height: 24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status Circle
            Center(child: _shimmerCircle()),
            const SizedBox(height: 12),
            _shimmerBox(width: 140),
            const SizedBox(height: 5),
            _shimmerBox(width: 180),

            const SizedBox(height: 20),

            // Issue List Placeholder
            Column(
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(
                        width: 80,
                        height: 20,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 6),
                      _shimmerBox(height: 14),
                      const SizedBox(height: 2),
                      _shimmerBox(height: 14),
                      const SizedBox(height: 6),
                      _shimmerBox(height: 12),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _shimmerCircle(size: 26),
                const SizedBox(width: 5),
                _shimmerBox(
                  width: 120,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _shimmerBox(
              height: 80,
              borderRadius: BorderRadius.circular(16),
            ),

            const SizedBox(height: 15),

            // Writing Tips Placeholder
            Row(
              children: [
                _shimmerCircle(size: 26),
                const SizedBox(width: 10),
                _shimmerBox(
                  width: 140,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Column(
              children: List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _shimmerBox(
                    height: 14,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
