import 'package:flutter/material.dart';

import '../../app_colors.dart';

class CustomClickableText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final TextStyle? style; // Add this line

  const CustomClickableText({super.key,
    required this.text,
    required this.onTap,
    this.style, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: style ?? Theme.of(context).textTheme.titleSmall!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryColor,
        ),
      ),
    );
  }
}