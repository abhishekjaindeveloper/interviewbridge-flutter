import 'package:flutter/material.dart';
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

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
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
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
          ),
        ),
      ],
    );
  }
}
