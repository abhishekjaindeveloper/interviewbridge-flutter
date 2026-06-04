class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8080';

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

  // Question & Evaluation Endpoints
  static const String practiceQuestions = '/api/user/practice-questions';
}
