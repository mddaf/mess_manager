import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import 'locale_event.dart';
import 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(const LocaleState()) {
    on<LoadLocaleRequested>(_onLoadLocale);
    on<ChangeLocaleRequested>(_onChangeLocale);
  }

  Future<void> _onLoadLocale(
    LoadLocaleRequested event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(AppConstants.keyLocale);

    if (langCode != null && (langCode == 'en' || langCode == 'bn')) {
      emit(state.copyWith(locale: Locale(langCode)));
    }
  }

  Future<void> _onChangeLocale(
    ChangeLocaleRequested event,
    Emitter<LocaleState> emit,
  ) async {
    emit(state.copyWith(locale: event.locale));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLocale, event.locale.languageCode);
  }
}
