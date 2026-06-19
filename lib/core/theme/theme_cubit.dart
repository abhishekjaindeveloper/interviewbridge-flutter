import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_storage_service.dart';
import 'theme_constants.dart';
import 'app_colors.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeStorageService _storageService;

  ThemeCubit(this._storageService, ThemeMode initialTheme) : super(initialTheme);

  void setTheme(ThemeMode themeMode) async {
    String themeStr = ThemeConstants.themeLight;
    if (themeMode == ThemeMode.dark) {
      themeStr = ThemeConstants.themeDark;
      AppColors.setToDark();
    } else if (themeMode == ThemeMode.system) {
      themeStr = ThemeConstants.themeSystem;
      // We don't change AppColors directly here; it's handled dynamic in app.dart via build context watching platformBrightness.
    } else {
      AppColors.setToLight();
    }
    
    await _storageService.writeTheme(themeStr);
    emit(themeMode);
  }
}
