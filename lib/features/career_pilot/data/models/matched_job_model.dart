import '../../domain/entities/matched_job_entity.dart';

class MatchedJobModel extends MatchedJobEntity {
  const MatchedJobModel({
    required super.id,
    super.provider,
    super.externalJobId,
    required super.company,
    required super.title,
    required super.description,
    super.location,
    super.salaryMin,
    super.salaryMax,
    super.employmentType,
    super.workMode,
    super.applyUrl,
    super.companyLogo,
    super.tags,
    super.postedAt,
    required super.matchScore,
  });

  factory MatchedJobModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedPostedAt;
    if (json['postedAt'] != null) {
      try {
        parsedPostedAt = DateTime.parse(json['postedAt'].toString());
      } catch (_) {
        parsedPostedAt = null;
      }
    }

    String? parsedTags;
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        parsedTags = (json['tags'] as List).map((e) => e.toString()).join(', ');
      } else {
        parsedTags = json['tags'].toString();
      }
    }

    return MatchedJobModel(
      id: (json['id'] ?? '').toString(),
      provider: json['provider']?.toString(),
      externalJobId: json['externalJobId']?.toString(),
      company: json['company']?.toString() ?? 'Unknown Company',
      title: json['title']?.toString() ?? 'Untitled Position',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString(),
      salaryMin: json['salaryMin'] != null ? (json['salaryMin'] as num).toDouble() : null,
      salaryMax: json['salaryMax'] != null ? (json['salaryMax'] as num).toDouble() : null,
      employmentType: json['employmentType']?.toString(),
      workMode: json['workMode']?.toString(),
      applyUrl: json['applyUrl']?.toString(),
      companyLogo: json['companyLogo']?.toString(),
      tags: parsedTags,
      postedAt: parsedPostedAt,
      matchScore: json['matchScore'] != null ? (json['matchScore'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'externalJobId': externalJobId,
      'company': company,
      'title': title,
      'description': description,
      'location': location,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'employmentType': employmentType,
      'workMode': workMode,
      'applyUrl': applyUrl,
      'companyLogo': companyLogo,
      'tags': tags,
      'postedAt': postedAt?.toIso8601String(),
      'matchScore': matchScore,
    };
  }
}
