import 'package:equatable/equatable.dart';

class PracticeSessionEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String technologyId;
  final String technologyName;
  final String experienceId;
  final String experienceLabel;
  final String sessionStatus;
  final int totalQuestions;
  final int completedQuestions;
  final double averageScore;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PracticeSessionEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.technologyId,
    required this.technologyName,
    required this.experienceId,
    required this.experienceLabel,
    required this.sessionStatus,
    required this.totalQuestions,
    required this.completedQuestions,
    required this.averageScore,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        technologyId,
        technologyName,
        experienceId,
        experienceLabel,
        sessionStatus,
        totalQuestions,
        completedQuestions,
        averageScore,
        startedAt,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
