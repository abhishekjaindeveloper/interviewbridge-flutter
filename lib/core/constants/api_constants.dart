enum AppEnvironment {
  development,
  staging,
  production,
}

class ApiConstants {
  ApiConstants._();

  static const String _devUrl = 'http://10.11.8.94:9000';
  static const String _stagingUrl = 'https://staging-api.interviewbridge.com';
  static const String _prodUrl = 'https://api.interviewbridge.com';

  static AppEnvironment get environment {
    const envString = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (envString.toLowerCase()) {
      case 'staging':
        return AppEnvironment.staging;
      case 'prod':
      case 'production':
        return AppEnvironment.production;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.development;
    }
  }

  static String get baseUrl {
    switch (environment) {
      case AppEnvironment.development:
        return const String.fromEnvironment('API_DEV_URL', defaultValue: _devUrl);
      case AppEnvironment.staging:
        return const String.fromEnvironment('API_STAGING_URL', defaultValue: _stagingUrl);
      case AppEnvironment.production:
        return const String.fromEnvironment('API_PROD_URL', defaultValue: _prodUrl);
    }
  }

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
  
  // Auth Endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';

  // Admin Endpoints
  static const String adminPendingUsers = '/api/admin/users/pending';
  static const String adminApproveUser = '/api/admin/users'; // Append /{id}/approve
  static const String adminRejectUser = '/api/admin/users';  // Append /{id}/reject
  static const String adminUsers = '/api/admin/users';
  static const String adminUsersSearch = '/api/admin/users/search';
  static const String adminUsersStatistics = '/api/admin/users/statistics';

  // Technology Endpoints
  static const String adminTechnologies = '/api/admin/technologies';
  static const String userTechnologies = '/api/user/technologies';

  // Experience Endpoints
  static const String adminExperiences = '/api/admin/experiences';
  static const String userExperiences = '/api/user/experiences';

  // Profile Endpoints
  static const String userProfile = '/api/user/profile';
  static const String userProfileSetup = '/api/user/profile/setup';
  static const String userProfileSelection = '/api/user/profile/setup';

  // Practice Session Endpoints
  static const String practiceSessions = '/api/user/practice-sessions';
  static String generateQuestionsUrl(String sessionId) => '$practiceSessions/$sessionId/questions/generate';

  // Question & Evaluation Endpoints
  static const String practiceQuestions = '/api/user/practice-questions';
  static String sessionQuestionsUrl(String sessionId) => '$practiceSessions/$sessionId/questions';
  static String questionByNumberUrl(String sessionId, int num) => '$practiceSessions/$sessionId/questions/$num';
  static String questionDetailsUrl(String questionId) => '$practiceQuestions/$questionId';
  static String submitAnswerUrl(String questionId) => '$practiceQuestions/$questionId/answer';
  static String evaluateQuestionUrl(String questionId) => '$practiceQuestions/$questionId/evaluate';
  static String questionEvaluationUrl(String questionId) => '$practiceQuestions/$questionId/evaluation';
}
