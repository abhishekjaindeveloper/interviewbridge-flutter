import 'package:flutter/services.dart';

class LoginInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }
    
    // If input starts as numeric, treat it as phone login
    final firstChar = text[0];
    final isNumeric = RegExp(r'[0-9]').hasMatch(firstChar);
    
    if (isNumeric) {
      // Allow only digits
      final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Limit to 10 digits
      if (cleanText.length > 10) {
        final limitedText = cleanText.substring(0, 10);
        return TextEditingValue(
          text: limitedText,
          selection: TextSelection.collapsed(offset: limitedText.length),
        );
      }
      
      // Return cleaned text
      if (text != cleanText) {
        int offset = newValue.selection.end;
        if (offset > cleanText.length) {
          offset = cleanText.length;
        }
        return TextEditingValue(
          text: cleanText,
          selection: TextSelection.collapsed(offset: offset),
        );
      }
      
      return newValue;
    }
    
    // Email login continues working normally (no restrictions)
    return newValue;
  }
}
