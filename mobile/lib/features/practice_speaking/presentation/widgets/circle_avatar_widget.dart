import 'package:flutter/material.dart';

class CircleAvatarWidget extends StatelessWidget {
  final double padd;
  final double radius;
  const CircleAvatarWidget({
    super.key,
    required this.radius,
    required this.padd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (radius),
      height: (radius),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        gradient: LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF34D399)],
          begin: Alignment.centerRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padd),
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: ClipOval(
            child: Image.asset('assets/images/avatar.png', fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
