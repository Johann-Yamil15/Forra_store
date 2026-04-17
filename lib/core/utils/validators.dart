import 'package:forra_store/core/constants/strings.dart';

class Validators {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseEnterUsername;
    }
    if (value.length < 4) {
      return AppStrings.usernameMinLength;
    }
    if (value.length > 20) {
      return AppStrings.usernameMaxLength;
    }
    if (value.contains(' ')) {
      return AppStrings.usernameNoSpaces;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseEnterPassword;
    }
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    if (value.contains(' ')) {
      return AppStrings.passwordNoSpaces;
    }
    return null;
  }
}
