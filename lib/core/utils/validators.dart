import '../constants/validation_constants.dart';
import '../constants/app_constants.dart';

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

  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.emailOrPhoneRequired;
    }
    
    final trimmed = value.trim();
    
    // Check if input starts as numeric
    final isNumericPhone = trimmed.isNotEmpty && RegExp(r'^[0-9]').hasMatch(trimmed[0]);
    
    if (isNumericPhone) {
      final phoneRegex = RegExp(r'^[6-9][0-9]{9}$');
      if (!phoneRegex.hasMatch(trimmed)) {
        return AppConstants.invalidPhoneNumberMessage;
      }
      return null;
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(trimmed)) {
        return AppConstants.invalidEmailOrPhone;
      }
      return null;
    }
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

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.phoneNumberRequired;
    }
    final trimmed = value.trim();
    final phoneRegex = RegExp(r'^[6-9][0-9]{9}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return AppConstants.invalidPhoneNumberMessage;
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
