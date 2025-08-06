import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessAnimationDialog extends StatelessWidget {
  final VoidCallback onCompleted;
  final double width;  // animation width
  final double height; // animation height
  final Duration delay; // custom delay before calling onCompleted

  const SuccessAnimationDialog({
    super.key,
    required this.onCompleted,
    this.width = 150,
    this.height = 150,
    this.delay = const Duration(seconds: 0),
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      elevation: 0,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width,
            height: height,
            child: Lottie.asset(
              'assets/animations/success.json',
              repeat: false,
              onLoaded: (composition) {
                // Use the custom delay instead of composition.duration
                Future.delayed(delay, () {
                  Future.delayed(delay, () {
                    onCompleted();  // Direct call without addPostFrameCallback
                  });
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Registration Successful!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
