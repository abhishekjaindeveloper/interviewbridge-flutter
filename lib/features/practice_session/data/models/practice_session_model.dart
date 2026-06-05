import '../../domain/entities/practice_session_entity.dart';

class PracticeSessionModel extends PracticeSessionEntity {
  const PracticeSessionModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.technologyId,
    required super.technologyName,
    required super.experienceId,
    required super.experienceLabel,
    required super.sessionStatus,
    required super.totalQuestions,
    required super.completedQuestions,
    required super.averageScore,
    super.startedAt,
    super.completedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory PracticeSessionModel.fromJson(Map<String, dynamic> json) {
    return PracticeSessionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      technologyId: json['technologyId'] as String? ?? '',
      technologyName: json['technologyName'] as String? ?? '',
      experienceId: json['experienceId'] as String? ?? '',
      experienceLabel: json['experienceLabel'] as String? ?? '',
      sessionStatus: json['sessionStatus'] as String? ?? '',
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      completedQuestions: json['completedQuestions'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'technologyId': technologyId,
      'technologyName': technologyName,
      'experienceId': experienceId,
      'experienceLabel': experienceLabel,
      'sessionStatus': sessionStatus,
      'totalQuestions': totalQuestions,
      'completedQuestions': completedQuestions,
      'averageScore': averageScore,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PracticeSessionEntity toEntity() {
    return PracticeSessionEntity(
      id: id,
      userId: userId,
      userName: userName,
      technologyId: technologyId,
      technologyName: technologyName,
      experienceId: experienceId,
      experienceLabel: experienceLabel,
      sessionStatus: sessionStatus,
      totalQuestions: totalQuestions,
      completedQuestions: completedQuestions,
      averageScore: averageScore,
      startedAt: startedAt,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
