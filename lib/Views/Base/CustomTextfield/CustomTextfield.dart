import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../Utils/AppColor/app_colors.dart';
import '../../../Utils/AppIcon/app_icon.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final Color? borderColor;
  final Color? filColor;
  final dynamic prefixIcon; // Widget or String (SVG path)
  final dynamic suffixIcon; // Widget or String (SVG path)
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final String? labelText;
  final String? hintText;
  final double? contentPaddingHorizontal;
  final double? contentPaddingVertical;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final bool? isEmail;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final bool? enabled;
  final String obscure;

  const CustomTextField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.borderColor,
    this.filColor,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconColor,
    this.suffixIconColor,
    this.labelText,
    this.hintText,
    this.contentPaddingHorizontal,
    this.contentPaddingVertical,
    this.validator,
    this.isPassword = false,
    this.isEmail,
    this.autovalidateMode,
    this.onChanged,
    this.maxLines,
    this.enabled,
    this.onSubmitted,
    this.obscure = '*',
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  void toggle() => setState(() => obscureText = !obscureText);

  Widget? _buildIcon(dynamic icon, {double size = 20, Color? color}) {
    if (icon == null) return null;
    if (icon is Widget) return icon;
    if (icon is String) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: SvgPicture.asset(
          icon,
          width: size,
          height: size,
          color: color,
        ),
      );
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputTheme = Theme.of(context).inputDecorationTheme;
    final prefixColor = widget.prefixIconColor ?? inputTheme.prefixIconColor;
    final suffixColor = widget.suffixIconColor ?? inputTheme.suffixIconColor;

    return TextFormField(
      onFieldSubmitted: (value) => widget.onSubmitted?.call(value),
      controller: widget.controller,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      obscureText: widget.isPassword ? obscureText : false,
      obscuringCharacter: widget.obscure,
      enabled: widget.enabled ?? true,
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
      validator: widget.validator ?? (value) {
            if (value == null || value.isEmpty) {
              return "Please enter ${widget.hintText?.toLowerCase() ?? 'this field'}";
            }
            if (widget.isEmail == true) {
              final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
              if (!emailRegex.hasMatch(value)) return "Please enter a valid email";
            }
            return null;
          },
      onChanged: widget.onChanged,
      cursorColor: isDark ? AppColors.DarkThemeText : AppColors.DarkBlue,
      style: TextStyle(
        color: isDark ? AppColors.DarkThemeText : AppColors.DarkBlue,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        filled: widget.filColor != null,
        fillColor: widget.filColor ?? (isDark ? AppColors.White : null),
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.contentPaddingHorizontal ?? 12,
          vertical: widget.contentPaddingVertical ?? 14,
        ),
        prefixIcon: _buildIcon(widget.prefixIcon, color: prefixColor),
        suffixIcon: widget.isPassword ? GestureDetector(
          onTap: toggle,
          child: _buildIcon(
            obscureText ? AppIcons.hide : AppIcons.show,
            size: 16,
            color: suffixColor,
          ),
        ):_buildIcon(widget.suffixIcon, color: suffixColor),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: widget.borderColor ??
                (isDark ? AppColors.DarkThemeText.withValues(alpha: 0.70)
                    : AppColors.blue500.withValues(alpha: 0.70)),
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark ? AppColors.Red.withValues(alpha: 0.30)
                  : AppColors.Red
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.Red.withValues(alpha: 0.30)
                : AppColors.Red,
            width: 1.1,
          ),
        ),
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.DarkThemeSecondaryText
              : Theme.of(context).textTheme.titleSmall?.color,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
