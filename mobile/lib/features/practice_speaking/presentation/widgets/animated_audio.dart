

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/widgets/record_free_speech_audio.dart';





class AnimatedAudioBlob extends StatelessWidget {
  static const _numPoints = 32;
  static const _minRadius = 45.0; 
  static const _maxRadius = 60.0; 
  

  final ConversationState state;
  final double volume; 
  final VoidCallback onTap;

  const AnimatedAudioBlob({
    super.key,
    required this.state,
    required this.volume,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    
    final Color blobColor = _getColorForState(state);

    
    final volumeTween = Tween<double>(begin: 0.0, end: volume.clamp(0.0, 1.0));

    
    return LoopAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 2 * pi), 
      duration: const Duration(seconds: 10),
      builder: (context, value, child) {
        
        return PlayAnimationBuilder<double>(
          tween: volumeTween,
          duration: const Duration(milliseconds: 100),
          builder: (context, animatedVolume, child) {
            final List<double> targetRadii = _generateTargetRadii(
              value,
              animatedVolume,
            );
            return GestureDetector(
              onTap: onTap,
              child: CustomPaint(
                size: const Size(150, 150),
                painter: BlobPainter(
                  radii: targetRadii,
                  color: blobColor,
                  isListening:
                      state == ConversationState.listening ||
                      state == ConversationState.speaking,
                ),
              ),
            );
          },
        );
      },
    );
  }

  
  List<double> _generateTargetRadii(
    double animationValue,
    double currentVolume,
  ) {
    final List<double> radii = [];
    for (int i = 0; i < _numPoints; i++) {
      final double angle = i * (2 * pi / _numPoints);
      
      final double organicOffset = sin(angle * 4 + animationValue) * 3;
      
      final double volumeOffset = currentVolume * (_maxRadius - _minRadius);
      radii.add(_minRadius + organicOffset + volumeOffset);
    }
    return radii;
  }

  Color _getColorForState(ConversationState state) {
    switch (state) {
      case ConversationState.idle:
        return Colors.grey;
      case ConversationState.connected:
        return Colors.blue;
      case ConversationState.listening:
        return Colors.red;
      case ConversationState.processing:
        return Colors.amber;
      case ConversationState.speaking:
        return Colors.lightBlue;
    }
  }
}

class BlobPainter extends CustomPainter {
  final List<double> radii;
  final Color color;
  final bool isListening;

  BlobPainter({
    required this.radii,
    required this.color,
    this.isListening = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();

    final angleStep = (2 * pi) / radii.length;
    final points = <Offset>[];
    for (int i = 0; i < radii.length; i++) {
      final angle = i * angleStep;
      final x = center.dx + radii[i] * cos(angle);
      final y = center.dy + radii[i] * sin(angle);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];
      final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      path.quadraticBezierTo(p1.dx, p1.dy, midPoint.dx, midPoint.dy);
    }
    path.close();

    
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawPath(path, shadowPaint);

    
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BlobPainter oldDelegate) {
    return oldDelegate.radii != radii || oldDelegate.color != color;
  }
}
