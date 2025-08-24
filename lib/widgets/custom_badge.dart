import 'package:flutter/material.dart';

enum BadgeVariant { primary, secondary, outline }

class CustomBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const CustomBadge({
    required this.text,
    this.variant = BadgeVariant.primary,
    this.backgroundColor,
    this.textColor,
    this.size,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color txtColor;
    BorderSide borderSide;

    switch (variant) {
      case BadgeVariant.primary:
        bgColor = backgroundColor ?? theme.primaryColor;
        txtColor = textColor ?? Colors.white;
        borderSide = BorderSide.none;
        break;
      case BadgeVariant.secondary:
        bgColor = backgroundColor ?? Colors.grey[200]!;
        txtColor = textColor ?? Colors.black;
        borderSide = BorderSide.none;
        break;
      case BadgeVariant.outline:
        bgColor = Colors.transparent;
        txtColor = textColor ?? theme.primaryColor;
        borderSide = BorderSide(color: theme.primaryColor);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.fromBorderSide(borderSide),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: txtColor,
                fontSize: size ?? 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onClose != null) ...[
              SizedBox(width: 4),
              GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, size: (size ?? 12) - 2, color: txtColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}