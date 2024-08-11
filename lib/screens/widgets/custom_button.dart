import 'package:flutter/material.dart';

import '../../app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? borderColor;
  final Widget? prefix;
  final double? radius;
  final Widget? suffix;
  final VoidCallback onPressed;
  final TextStyle? style;

  final bool isEnabled;
  final Size? size;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,  this.size,  this.color,  this.style, this.prefix, this.suffix, this.radius, this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        fixedSize: size??Size(343, 44),
        backgroundColor:color ?? (isEnabled ? AppColors.primaryColor : AppColors.buttonDisableBlueColor),
        disabledBackgroundColor: AppColors.buttonDisableBlueColor,
        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(radius??8),
          side: BorderSide(color: borderColor??Colors.transparent)
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            prefix??SizedBox(),
            Text(
              " $label ",
              style:style?? Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteColor,
              ),
            ),
            suffix??const SizedBox()
          ],
        ),
      ),
    );
  }
}
