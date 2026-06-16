import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/routes/route_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/auth_card_widget.dart';
import '../widgets/auth_footer_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
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
          if (state is AuthError) {
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
                      title: AppConstants.loginTitle,
                      subtitle: AppConstants.loginSubtitle,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CustomTextField(
                      labelText: AppConstants.emailOrPhoneLabel,
                      hintText: AppConstants.emailOrPhoneHint,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmailOrPhone,
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
                    const SizedBox(height: AppSpacing.xl),
                    CustomButton(
                      text: AppConstants.loginButton,
                      onPressed: isLoading ? null : _onLoginPressed,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AuthFooterWidget(
                      message: AppConstants.noAccountText,
                      actionText: AppConstants.registerLink,
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.register);
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
