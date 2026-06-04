import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/validation_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/auth_card_widget.dart';
import '../widgets/auth_footer_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterRequested(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: AuthCardWidget(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeaderWidget(
                      title: AppConstants.registerTitle,
                      subtitle: AppConstants.registerSubtitle,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CustomTextField(
                      labelText: AppConstants.fullNameLabel,
                      hintText: AppConstants.fullNameHint,
                      controller: _nameController,
                      validator: Validators.validateName,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      labelText: AppConstants.emailLabel,
                      hintText: AppConstants.emailHint,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      labelText: AppConstants.passwordLabel,
                      hintText: AppConstants.passwordHint,
                      controller: _passwordController,
                      obscureText: true,
                      validator: Validators.validatePassword,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      labelText: AppConstants.confirmPasswordLabel,
                      hintText: AppConstants.confirmPasswordHint,
                      controller: _confirmPasswordController,
                      obscureText: true,
                      enabled: !isLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return ValidationConstants.passwordRequired;
                        }
                        if (value.trim() != _passwordController.text.trim()) {
                          return AppConstants.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CustomButton(
                      text: AppConstants.registerButton,
                      onPressed: isLoading ? null : _onRegisterPressed,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AuthFooterWidget(
                      message: AppConstants.alreadyHaveAccountText,
                      actionText: AppConstants.loginLink,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
