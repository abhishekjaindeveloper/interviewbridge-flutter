import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/route_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _entranceController;

  late Animation<Alignment> _alignmentBegin;
  late Animation<Alignment> _alignmentEnd;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  bool _timerFinished = false;

  @override
  void initState() {
    super.initState();

    final authBloc = context.read<AuthBloc>();
    if (authBloc.state is AuthInitial) {
      authBloc.add(AuthStarted());
    }

    // Gradient background controller - runs continuously
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _alignmentBegin = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomLeft,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    _alignmentEnd = Tween<Alignment>(
      begin: Alignment.bottomRight,
      end: Alignment.topRight,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    // Entrance animation controller - runs once
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();

    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _timerFinished = true;
        });
        _checkNavigation();
      }
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _checkNavigation() {
    if (!_timerFinished) return;

    final authState = context.read<AuthBloc>().state;

    if (authState is AuthInitial || authState is AuthLoading) {
      return;
    }

    if (authState is Authenticated) {
      Navigator.of(context).pushReplacementNamed(RouteConstants.home);
    } else {
      Navigator.of(context).pushReplacementNamed(RouteConstants.landing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _alignmentBegin.value,
                end: _alignmentEnd.value,
                colors: [
                  AppColors.background,
                  AppColors.surface,
                ],
              ),
            ),
            child: child,
          ),
        );
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is! AuthInitial && state is! AuthLoading) {
            _checkNavigation();
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          height: AppDimensions.logoSize * 1.5,
                          width: AppDimensions.logoSize * 1.5,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: SlideTransition(
                      position: _textSlideAnimation,
                      child: Column(
                        children: [
                          Text(
                            AppConstants.appName,
                            style: AppTypography.headingLarge.copyWith(
                              fontSize: 40,
                              letterSpacing: -1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            AppConstants.splashTagline,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 18,
                              color: AppColors.primaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}