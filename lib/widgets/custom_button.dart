import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, destructive }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final bool isLoading;

  const CustomButton({
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BorderSide borderSide;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = AppColors.buttonPrimary;
        textColor = Colors.white;
        borderSide = BorderSide.none;
        break;
      case ButtonVariant.secondary:
        backgroundColor = AppColors.buttonSecondary;
        textColor = Colors.white;
        borderSide = BorderSide.none;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = AppColors.buttonPrimary;
        borderSide = BorderSide(color: AppColors.buttonPrimary);
        break;
      case ButtonVariant.destructive:
        backgroundColor = AppColors.error;
        textColor = Colors.white;
        borderSide = BorderSide.none;
        break;
    }

    double height;
    EdgeInsets padding;
    TextStyle textStyle;

    switch (size) {
      case ButtonSize.small:
        height = 32;
        padding = EdgeInsets.symmetric(horizontal: 12);
        textStyle = TextStyle(fontSize: 14);
        break;
      case ButtonSize.medium:
        height = 40;
        padding = EdgeInsets.symmetric(horizontal: 16);
        textStyle = TextStyle(fontSize: 16);
        break;
      case ButtonSize.large:
        height = 48;
        padding = EdgeInsets.symmetric(horizontal: 24);
        textStyle = TextStyle(fontSize: 18);
        break;
    }

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: borderSide,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(textColor),
          strokeWidth: 2,
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              SizedBox(width: 8),
            ],
            Text(text, style: textStyle),
          ],
        ),
      ),
    );
  }
}