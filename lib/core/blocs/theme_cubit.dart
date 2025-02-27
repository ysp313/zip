import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;

  ThemeCubit() : super(ThemeMode.system) {
    _loadFromPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadFromPrefs() async {
    await _initPrefs();
    final themeIndex = _prefs.getInt(_themeKey) ?? 0;
    emit(ThemeMode.values[themeIndex]);
  }

  Future<void> _saveToPrefs() async {
    await _initPrefs();
    await _prefs.setInt(_themeKey, state.index);
  }

  void setThemeMode(ThemeMode mode) {
    emit(mode);
    _saveToPrefs();
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }
}
