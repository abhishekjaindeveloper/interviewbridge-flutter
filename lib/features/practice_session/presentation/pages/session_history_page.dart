// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/practice_session_bloc.dart';
import '../bloc/practice_session_event.dart';
import '../bloc/practice_session_state.dart';
import '../widgets/session_card_widget.dart';
import '../../../../core/routes/route_constants.dart';

class SessionHistoryPage extends StatefulWidget {
  const SessionHistoryPage({super.key});

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<PracticeSessionBloc>().add(LoadSessionHistoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppConstants.sessionHistoryTitle,
          style: AppTypography.headingMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<PracticeSessionBloc, PracticeSessionState>(
        builder: (context, state) {
          if (state is PracticeSessionLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is PracticeSessionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  state.message,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is PracticeSessionsEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      color: AppColors.textSecondary,
                      size: 64,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      AppConstants.noSessionsFoundText,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is PracticeSessionsLoaded) {
            final sessions = state.sessions;
            return SafeArea(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.maxContentWidth,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        AppConstants.sessionHistorySubtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Expanded(
                        child: ListView.separated(
                          itemCount: sessions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            return SessionCardWidget(
                              session: session,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  RouteConstants.sessionActive,
                                  arguments: session.id,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
