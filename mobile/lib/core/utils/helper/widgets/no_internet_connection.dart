import 'package:flutter/material.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            width: 150,
            height: 150,
            'assets/videos/cryingmascot.gif',
          ),
          const Text('please check your internet connection'),
        ],
      ),
    );
  }
}
