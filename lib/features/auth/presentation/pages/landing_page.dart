// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/routes/route_constants.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final Timer _carouselTimer;
  int _currentCarouselPage = 0;
  static const int _virtualPageCount = 10000;

  late final AnimationController _entranceController;
  late final Animation<double> _heroFadeAnimation;
  late final Animation<double> _heroScaleAnimation;
  late final Animation<Offset> _heroSlideAnimation;

  late final Animation<double> _carouselFadeAnimation;
  late final Animation<Offset> _carouselSlideAnimation;

  late final Animation<double> _ctaFadeAnimation;
  late final Animation<Offset> _ctaSlideAnimation;

  final List<_FeatureItem> _features = const [
    _FeatureItem(
      icon: Icons.psychology,
      title: AppConstants.featureAiEvalTitle,
      description: AppConstants.featureAiEvalDesc,
    ),
    _FeatureItem(
      icon: Icons.forum,
      title: AppConstants.featurePracticeTitle,
      description: AppConstants.featurePracticeDesc,
    ),
    _FeatureItem(
      icon: Icons.trending_up,
      title: AppConstants.featureTrackingTitle,
      description: AppConstants.featureTrackingDesc,
    ),
    _FeatureItem(
      icon: Icons.thumb_up_alt,
      title: AppConstants.featureFeedbackTitle,
      description: AppConstants.featureFeedbackDesc,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Carousel Setup
    final initialPage = _virtualPageCount ~/ 2;
    _currentCarouselPage = initialPage % _features.length;
    _pageController = PageController(initialPage: initialPage);

    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    // Staggered Entrance Animations
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _heroScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _carouselFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );
    _carouselSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _ctaFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );
    _ctaSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _carouselTimer.cancel();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.maxContentWidth,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  FadeTransition(
                    opacity: _heroFadeAnimation,
                    child: ScaleTransition(
                      scale: _heroScaleAnimation,
                      child: SlideTransition(
                        position: _heroSlideAnimation,
                        child: _buildHeroSection(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeTransition(
                    opacity: _carouselFadeAnimation,
                    child: SlideTransition(
                      position: _carouselSlideAnimation,
                      child: _buildFeaturesSection(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FadeTransition(
                    opacity: _ctaFadeAnimation,
                    child: SlideTransition(
                      position: _ctaSlideAnimation,
                      child: _buildCtaSection(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: AppColors.primary.withOpacity(AppDimensions.opacityLow),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(AppDimensions.opacityLow),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
            child: Image.asset(
              'assets/icon/app_icon.png',
              height: AppDimensions.logoSize,
              width: AppDimensions.logoSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppConstants.landingTitle,
          style: AppTypography.headingLarge.copyWith(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppConstants.landingHeroTitle,
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.primaryLight,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppConstants.landingHeroSubtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppConstants.featuresTitle,
          style: AppTypography.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 160.0,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselPage = index % _features.length;
              });
            },
            itemBuilder: (context, index) {
              final feature = _features[index % _features.length];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: _buildFeatureItem(
                  icon: feature.icon,
                  title: feature.title,
                  description: feature.description,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_features.length, (index) {
            final isSelected = _currentCarouselPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 8.0,
              width: isSelected ? 24.0 : 8.0,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLight
                    : AppColors.border.withOpacity(AppDimensions.opacityBorder),
                borderRadius: BorderRadius.circular(4.0),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(AppDimensions.opacityHigh),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border.withOpacity(AppDimensions.opacityBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(AppDimensions.opacityLow),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryLight,
              size: AppSpacing.lg,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.headingSmall.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: AppConstants.getStartedButton,
          onPressed: () {
            Navigator.of(context).pushNamed(RouteConstants.login);
          },
        ),
      ],
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
