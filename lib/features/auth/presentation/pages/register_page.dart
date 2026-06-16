import 'package:flutter/material.dart';
//import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/validation_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/error_dialog.dart';
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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _termsAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
              phoneNumber: _phoneController.text.trim(),
              password: _passwordController.text.trim(),
              termsAccepted: _termsAccepted,
            ),
          );
    } else {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
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
            final isNetworkError = state.message == AppConstants.noConnection;
            ErrorDialog.show(
              context: context,
              title: isNetworkError
                  ? AppConstants.dialogTitleNetworkError
                  : AppConstants.dialogTitleAuthError,
              message: state.message,
              type: DialogType.error,
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
                      autovalidateMode: _autovalidateMode,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      labelText: AppConstants.emailLabel,
                      hintText: AppConstants.emailHint,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      autovalidateMode: _autovalidateMode,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      labelText: AppConstants.phoneNumberLabel,
                      hintText: AppConstants.phoneNumberHint,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                      autovalidateMode: _autovalidateMode,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      labelText: AppConstants.passwordLabel,
                      hintText: AppConstants.passwordHint,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: Validators.validatePassword,
                      autovalidateMode: _autovalidateMode,
                      enabled: !isLoading,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      labelText: AppConstants.confirmPasswordLabel,
                      hintText: AppConstants.confirmPasswordHint,
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      enabled: !isLoading,
                      autovalidateMode: _autovalidateMode,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return ValidationConstants.passwordRequired;
                        }
                        if (value.trim() != _passwordController.text.trim()) {
                          return AppConstants.passwordsDoNotMatch;
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FormField<bool>(
                      initialValue: false,
                      validator: (value) {
                        if (value != true) {
                          return ValidationConstants.termsRequired;
                        }
                        return null;
                      },
                      autovalidateMode: _autovalidateMode,
                      builder: (FormFieldState<bool> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: state.value ?? false,
                                  onChanged: isLoading
                                      ? null
                                      : (value) {
                                          state.didChange(value);
                                          setState(() {
                                            _termsAccepted = value ?? false;
                                          });
                                        },
                                  activeColor: AppColors.primary,
                                  checkColor: AppColors.white,
                                  side: const BorderSide(color: AppColors.border),
                                ),
                                Expanded(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        AppConstants.termsAgreementPrefix,
                                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(RouteConstants.termsConditions);
                                        },
                                        child: Text(
                                          AppConstants.termsConditionsLabel,
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        ' and ',
                                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(RouteConstants.privacyPolicy);
                                        },
                                        child: Text(
                                          AppConstants.privacyPolicyLabel,
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                                child: Text(
                                  state.errorText!,
                                  style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CustomButton(
                      text: AppConstants.registerButton,
                      onPressed: (isLoading || !_termsAccepted) ? null : _onRegisterPressed,
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
