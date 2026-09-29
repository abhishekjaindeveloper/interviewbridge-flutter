import 'package:equatable/equatable.dart';

class MatchedJobEntity extends Equatable {
  final String id;
  final String? provider;
  final String? externalJobId;
  final String company;
  final String title;
  final String description;
  final String? location;
  final double? salaryMin;
  final double? salaryMax;
  final String? employmentType;
  final String? workMode;
  final String? applyUrl;
  final String? companyLogo;
  final String? tags;
  final DateTime? postedAt;
  final int matchScore;

  const MatchedJobEntity({
    required this.id,
    this.provider,
    this.externalJobId,
    required this.company,
    required this.title,
    required this.description,
    this.location,
    this.salaryMin,
    this.salaryMax,
    this.employmentType,
    this.workMode,
    this.applyUrl,
    this.companyLogo,
    this.tags,
    this.postedAt,
    required this.matchScore,
  });

  @override
  List<Object?> get props => [
        id,
        provider,
        externalJobId,
        company,
        title,
        description,
        location,
        salaryMin,
        salaryMax,
        employmentType,
        workMode,
        applyUrl,
        companyLogo,
        tags,
        postedAt,
        matchScore,
      ];
}
