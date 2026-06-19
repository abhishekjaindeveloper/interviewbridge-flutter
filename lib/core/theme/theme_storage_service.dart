import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeStorageService {
  final FlutterSecureStorage _storage;
  static const String _themeKey = 'selected_theme';

  ThemeStorageService(this._storage);

  Future<void> writeTheme(String theme) async {
    await _storage.write(key: _themeKey, value: theme);
  }

  Future<String?> readTheme() async {
    return await _storage.read(key: _themeKey);
  }
}
