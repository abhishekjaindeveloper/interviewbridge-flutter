import '../constants/validation_constants.dart';

class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationConstants.emailRequired;
    }
    
    // Simple email validation regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return ValidationConstants.invalidEmail;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationConstants.passwordRequired;
    }
    if (value.trim().length < 6) {
      return ValidationConstants.passwordTooShort;
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationConstants.nameRequired;
    }
    return null;
  }
}
