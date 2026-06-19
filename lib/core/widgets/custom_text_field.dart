import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool enabled;
  final String? errorText;
  final AutovalidateMode? autovalidateMode;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.errorText,
    this.autovalidateMode,
    this.suffixIcon,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          style: AppTypography.bodyLarge,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
