import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<LoadThemeRequested>(_onLoadTheme);
    on<ToggleThemeRequested>(_onToggleTheme);
    on<SetThemeRequested>(_onSetTheme);
  }

  Future<void> _onLoadTheme(
    LoadThemeRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeStr = prefs.getString(AppConstants.keyThemeMode);

    if (savedThemeStr != null) {
      if (savedThemeStr == 'dark') {
        emit(state.copyWith(themeMode: ThemeMode.dark));
      } else if (savedThemeStr == 'light') {
        emit(state.copyWith(themeMode: ThemeMode.light));
      } else {
        emit(state.copyWith(themeMode: ThemeMode.system));
      }
    }
  }

  Future<void> _onToggleTheme(
    ToggleThemeRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final newMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(state.copyWith(themeMode: newMode));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyThemeMode,
      newMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> _onSetTheme(
    SetThemeRequested event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.themeMode));

    final prefs = await SharedPreferences.getInstance();
    String modeStr = 'system';
    if (event.themeMode == ThemeMode.dark) modeStr = 'dark';
    if (event.themeMode == ThemeMode.light) modeStr = 'light';
    await prefs.setString(AppConstants.keyThemeMode, modeStr);
  }
}
