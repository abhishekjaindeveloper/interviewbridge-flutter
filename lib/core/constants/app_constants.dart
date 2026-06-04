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
}
