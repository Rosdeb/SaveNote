import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../utils/Typography/app_typography.dart';
import '../../../../utils/AppSpacing/app_spacing.dart';
import '../../../../utils/SemanticColor/semantic_colors.dart';
import '../../../../utils/Typography/app_typography.dart';
import '../AppText/appText.dart';
import '../IOSTapEffect/iosTapEffect.dart';


class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double height;
  final double borderRadius;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height = 56,
    this.borderRadius = 16,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return IosTapEffect(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor ?? Colors.transparent,
          ),
          color: backgroundColor ?? SemanticColors.surfaceAction,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: AppText(
          text,
          style: AppTypography.buttonLarge,
          color: textColor ?? SemanticColors.textOnAction,
        ),
      ),
    );
  }
}