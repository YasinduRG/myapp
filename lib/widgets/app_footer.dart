import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/dpmc_footer.png'),
          fit: BoxFit.contain,
          // Handle image loading errors gracefully
          onError: _handleImageError,
        ),
      ),
    );
  }

  // Private helper to show an error message if the image fails to load
  static void _handleImageError(Object exception, StackTrace? stackTrace) {
    debugPrint("Footer image failed to load: $exception");
    // Optionally, you could display a fallback widget here
  }
}