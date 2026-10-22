import 'package:flutter/material.dart';
import '../styles/app_theme.dart';

class TopAccentStrip extends StatelessWidget {
  const TopAccentStrip({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the safe area top padding
    // We want the strip to be strictly inside the safe area (visual anchor)
    // or just 'safe-area aligned' meaning starting at safe area top.

    return Container(
      width: double.infinity,
      height: 3,
      color: AppTheme.primaryColor,
    );
  }
}
