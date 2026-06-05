class AppConstants {
  AppConstants._();

  static const String appName = 'InterviewBridge';

  // General App Message Strings
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String noConnection = 'No internet connection. Please verify your network.';
  static const String sessionExpired = 'Session expired. Please log in again.';
  
  // UI Design Defaults
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;

  // Authentication UI Strings
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Enter your credentials to access your account';
  static const String loginButton = 'Login';
  static const String noAccountText = "Don't have an account?";
  static const String registerLink = 'Register';
  static const String emailLabel = 'Email Address';
  static const String emailHint = 'Enter your email';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';

  static const String registerTitle = 'Create Account';
  static const String registerSubtitle = 'Fill in your details to register as a candidate';
  static const String registerButton = 'Register';
  static const String alreadyHaveAccountText = 'Already have an account?';
  static const String loginLink = 'Login';
  static const String fullNameLabel = 'Full Name';
  static const String fullNameHint = 'Enter your full name';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String confirmPasswordHint = 'Confirm your password';

  static const String pendingTitle = 'Approval Pending';
  static const String pendingSubtitle = 'Your account registration has been submitted and is currently pending administrator approval. You will receive access once approved.';
  static const String logoutButton = 'Logout';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  // Profile Strings
  static const String profileTitle = 'User Profile';
  static const String profileSubtitle = 'View and update your profile details';
  static const String nameLabel = 'Full Name';
  static const String emailLabelReadonly = 'Email Address (Readonly)';
  static const String roleLabel = 'Role (Readonly)';
  static const String approvalStatusLabel = 'Approval Status (Readonly)';
  static const String updateProfileButton = 'Update Name';
  static const String saveChangesButton = 'Save Changes';
  static const String cancelChangesButton = 'Cancel';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String setupSelectionButton = 'Complete Profile Setup';
  static const String changeSelectionButton = 'Update Selection';
  static const String selectedTechAndExp = 'Selected Technology & Experience';

  // Selection Strings
  static const String selectionTitle = 'Select Tech & Experience';
  static const String selectionSubtitle = 'Choose the technology and experience level for your practice sessions';
  static const String selectTechLabel = '1. Select Technology';
  static const String selectExpLabel = '2. Select Experience Level';
  static const String submitSelectionButton = 'Submit Selection';
  static const String selectionValidationWarning = 'Please select both a technology and an experience level.';
  static const String selectionSuccess = 'Selection submitted successfully!';
  static const String noTechAvailable = 'No active technologies available.';
  static const String noExpAvailable = 'No active experience levels available.';

  // Validation & Fields Strings
  static const String nameRequired = 'Name is required';
  static const String technologyLabel = 'Technology';
  static const String experienceLevelLabel = 'Experience Level';

  // Practice Session Strings
  static const String practiceDashboardTitle = 'Practice Dashboard';
  static const String practiceDashboardSubtitle = 'Configure and start a new interview practice session';
  static const String startPracticeButton = 'Start Practice Session';
  static const String goToPracticeSessionsButton = 'Go to Practice Sessions';
  static const String totalQuestionsSelectorLabel = 'Select Question Count';
  static const String recentSessionsLabel = 'Recent Sessions Preview';
  static const String viewAllHistoryButton = 'View All History';
  static const String noRecentSessionsText = 'No recent practice sessions found.';
  static const String incompleteProfileWarning = 'Please configure your technology and experience in your profile setup first.';
  static const String goToProfileSetupButton = 'Go to Profile Setup';
  static const String practiceSessionCreatedToast = 'Practice session created successfully!';
  static const String practiceQuestionsGeneratedToast = 'Practice questions generated successfully! Ready for practice.';

  // Session History Strings
  static const String sessionHistoryTitle = 'Session History';
  static const String sessionHistorySubtitle = 'Track and review all your past practice sessions';
  static const String noSessionsFoundText = 'No practice sessions found. Start your first session!';
  
  // Session Summary & Card Labels
  static const String sessionSummaryTitle = 'Session Summary';
  static const String sessionIdLabel = 'Session ID';
  static const String completedQuestionsLabel = 'Completed';
  static const String averageScoreLabel = 'Average Score';
  static const String statusLabel = 'Status';
  static const String startedAtLabel = 'Started At';
  static const String completedAtLabel = 'Completed At';
  static const String createdAtLabel = 'Created At';

  // Status Labels
  static const String statusCreated = 'Created';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';
  static const String statusUnknown = 'Unknown';

  // Audit Fix Constants
  static const String totalQuestionsLabel = 'Total Questions';
  static const String completedQuestionsLabelDetailed = 'Completed Questions';
  static const String readyForPracticeTitle = 'Ready for Practice';
  static const String closeButton = 'Close';
  static const String activeSelectionsTitle = 'Active Selections';
  static const String notAvailablePlaceholder = 'N/A';
  static const List<int> questionCountPresets = [5, 10, 15, 20];

  // Question Module UI Strings
  static const String questionPageTitle = 'Question Page';
  static const String resumeSessionSub = 'Resuming Practice Session';
  static const String previousQuestionButton = 'Previous';
  static const String nextQuestionButton = 'Next';
  static const String submitAnswerButton = 'Submit Answer';
  static const String finishViewEvaluationButton = 'Finish & View Evaluation';
  static const String answerInputPlaceholder = 'Enter your answer here...';
  static const String answerRequiredMsg = 'Answer cannot be empty';
  static const String duplicateSubmissionWarning = 'Duplicate submission prevented';
  static const String questionsCompletedBannerTitle = 'All questions completed!';
  static const String completedQuestionsProgressLabel = 'Completed Questions Progress';
  static const String questionStatusAnswered = 'Answered';
  static const String questionStatusPending = 'Pending';
  static const String questionStatusSkipped = 'Skipped';
  static const String emptyQuestionsText = 'No questions available for this session.';
  static const String answerSubmittedToast = 'Answer submitted successfully!';
  static const String proceedToEvaluationPrompt = 'Proceed to view the session evaluations.';
  static const String answerTooLongMsg = 'Answer cannot exceed 5000 characters';

  // Evaluation Screen Strings
  static const String evaluationPageTitle = 'AI Evaluation & Feedback';
  static const String evaluateButton = 'Evaluate Answer';
  static const String evaluatingStatus = 'AI is evaluating your response...';
  static const String userAnswerTitle = 'Your Answer';
  static const String translatedAnswerTitle = 'Translated Answer';
  static const String improvedAnswerTitle = 'Suggested Improvement';
  static const String explanationTitle = 'AI Feedback & Explanation';
  static const String notEvaluatedYet = 'Not Evaluated Yet';
  static const String evaluationCompleted = 'Evaluation Completed';
  static const String evaluationFailed = 'Evaluation Failed';
  static const String noEvaluationAvailable = 'No evaluation available for this question.';
  static const String scoreLabel = 'Score';
  static const String scoreOutOfTen = '/ 10';
  static const String backToHistoryButton = 'Back to Session History';
  static const String closeSessionButton = 'Finish Session';
  static const String triggerEvaluationTooltip = 'Evaluate answer using AI';
}
