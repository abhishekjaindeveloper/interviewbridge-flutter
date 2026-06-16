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
  static const String emailOrPhoneLabel = 'Email or Phone Number';
  static const String emailOrPhoneHint = 'Enter your email or phone number';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';

  static const String registerTitle = 'Create Account';
  static const String registerSubtitle = 'Fill in your details to register as a candidate';
  static const String registerButton = 'Register';
  static const String alreadyHaveAccountText = 'Already have an account?';
  static const String loginLink = 'Login';
  static const String fullNameLabel = 'Full Name';
  static const String fullNameHint = 'Enter your full name';
  static const String phoneNumberLabel = 'Phone Number';
  static const String phoneNumberHint = 'Enter your phone number';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String confirmPasswordHint = 'Confirm your password';

  static const String pendingTitle = 'Approval Pending';
  static const String pendingSubtitle = 'Your account registration has been submitted and is currently pending administrator approval. You will receive access once approved.';
  static const String logoutButton = 'Logout';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String okButton = 'OK';

  // Admin Dashboard Strings
  static const String adminDashboardTitle = 'Admin Panel';
  static const String menuDashboard = 'Dashboard';
  static const String menuPendingUsers = 'Pending Users';
  static const String menuTechnologyMaster = 'Technology Master';
  static const String menuExperienceMaster = 'Experience Master';
  static const String menuProfile = 'Profile';
  static const String menuLogout = 'Logout';
  static const String placeholderDashboard = 'Admin Dashboard Overview Placeholder';
  static const String placeholderPendingUsers = 'Pending User Approvals List Placeholder';
  static const String placeholderTechnologyMaster = 'Technology Master CRUD Placeholder';
  static const String placeholderExperienceMaster = 'Experience Master CRUD Placeholder';
  static const String placeholderProfile = 'Admin Profile Placeholder';

  // Dialog Titles
  static const String dialogTitleError = 'Error';
  static const String dialogTitleSuccess = 'Success';
  static const String dialogTitleWarning = 'Warning';
  static const String dialogTitleInfo = 'Information';
  static const String dialogTitleNetworkError = 'Network Error';
  static const String dialogTitleAuthError = 'Authentication Failure';
  static const String dialogTitleValidationError = 'Validation Failed';
  static const String dialogTitleServerError = 'Server Error';
  
  // Login Error Messages
  static const String errorPendingApproval = 'Your account is pending admin approval. Please wait for approval before logging in.';
  static const String errorRejected = 'Your account has been rejected. Please contact the administrator.';
  static const String errorInvalidCredentials = 'Invalid email or password.';
  static const String errorDisabledAccount = 'Your account is currently inactive.';

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

  // Splash & Landing Screen Strings
  static const String splashTagline = 'Practice. Improve. Get Hired.';
  static const String landingTitle = 'InterviewBridge';
  static const String landingHeroTitle = 'Master Your Next Technical Interview';
  static const String landingHeroSubtitle = 'Get instant AI feedback, practice real-world questions tailored to your technology and experience level, and track your progress.';
  static const String featuresTitle = 'Core Features';
  static const String featureAiEvalTitle = 'AI Interview Evaluation';
  static const String featureAiEvalDesc = 'Get deep insights, detailed explanations, and instant scores for your answers.';
  static const String featurePracticeTitle = 'Practice Sessions';
  static const String featurePracticeDesc = 'Simulate real interviews with customizable question sets tailored to your stack.';
  static const String featureTrackingTitle = 'Progress Tracking';
  static const String featureTrackingDesc = 'Monitor your performance over time and see how your scores improve.';
  static const String featureFeedbackTitle = 'Personalized Feedback';
  static const String featureFeedbackDesc = 'Receive translated answers and custom suggestions to elevate your responses.';
  static const String getStartedButton = 'Get Started';
  static const String landingLoginButton = 'Login';

  // Terms & Privacy Policy Strings
  static const String termsAgreementPrefix = 'I agree to the ';
  static const String termsConditionsLabel = 'Terms & Conditions';
  static const String privacyPolicyLabel = 'Privacy Policy';
  static const String termsConditionsTitle = 'Terms & Conditions';
  static const String privacyPolicyTitle = 'Privacy Policy';
  static const String termsConditionsText = 'Welcome to InterviewBridge. By registering and using our app, you agree to comply with our Terms & Conditions. You agree to use the service for personal growth, AI interview simulation, and professional skill enhancement. We reserve the right to suspend accounts violating acceptable use rules or behaving disruptively. All AI generated content is provided as-is without legal warranty.';
  static const String privacyPolicyText = 'Your privacy matters to us at InterviewBridge. We collect minimal personal credentials (name, email, and optionally phone number) strictly for user authentication, record mapping, and AI evaluations. Your inputs, generated questions, and feedback logs are securely cached and are not shared with unauthorized third-party commercial marketing systems.';

  // Admin User Management Strings
  static const String adminConfirmActionTitle = 'Confirm Action';
  static const String adminApproveConfirmMsg = 'Are you sure you want to approve this user?';
  static const String adminRejectConfirmMsg = 'Are you sure you want to reject this user?';
  static const String adminNoPendingUsers = 'No pending users found.';
  static const String adminLoadPendingFailed = 'Failed to load pending users.';
  static const String adminRetryButton = 'Retry';
  static const String adminConfirmButton = 'Confirm';
  static const String adminCancelButton = 'Cancel';
  static const String adminApproveButton = 'Approve';
  static const String adminRejectButton = 'Reject';
  static const String adminRegistrationDateLabel = 'Registration Date';

  // Admin Master CRUD Strings
  static const String techMasterTitle = 'Technology Master';
  static const String techNameLabel = 'Technology Name';
  static const String techDescLabel = 'Description';
  static const String techStatusLabel = 'Status';
  static const String addTechTitle = 'Add Technology';
  static const String editTechTitle = 'Edit Technology';
  static const String techCreateSuccess = 'Technology created successfully.';
  static const String techUpdateSuccess = 'Technology updated successfully.';
  static const String techActivateSuccess = 'Technology activated successfully.';
  static const String techDeactivateSuccess = 'Technology deactivated successfully.';
  static const String techActivateConfirmMsg = 'Are you sure you want to activate this technology?';
  static const String techDeactivateConfirmMsg = 'Are you sure you want to deactivate this technology?';
  static const String techNameRequired = 'Technology name is required.';
  static const String techLoadFailed = 'Failed to load technologies.';
  static const String techNoRecords = 'No technologies found.';

  static const String expMasterTitle = 'Experience Master';
  static const String expLabelLabel = 'Experience Label';
  static const String addExpTitle = 'Add Experience Level';
  static const String editExpTitle = 'Edit Experience Level';
  static const String expCreateSuccess = 'Experience level created successfully.';
  static const String expUpdateSuccess = 'Experience level updated successfully.';
  static const String expActivateSuccess = 'Experience level activated successfully.';
  static const String expDeactivateSuccess = 'Experience level deactivated successfully.';
  static const String expActivateConfirmMsg = 'Are you sure you want to activate this experience level?';
  static const String expDeactivateConfirmMsg = 'Are you sure you want to deactivate this experience level?';
  static const String expLabelRequired = 'Experience label is required.';
  static const String expLoadFailed = 'Failed to load experience levels.';
  static const String expNoRecords = 'No experience levels found.';

  static const String statusActive = 'Active';
  static const String statusInactive = 'Inactive';
  static const String btnSave = 'Save';
  static const String btnCreate = 'Create';
  static const String btnActivate = 'Activate';
  static const String btnDeactivate = 'Deactivate';
  static const String searchPlaceholder = 'Search...';
}
