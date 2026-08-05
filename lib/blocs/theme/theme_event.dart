import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemeRequested extends ThemeEvent {}

class ToggleThemeRequested extends ThemeEvent {}

class SetThemeRequested extends ThemeEvent {
  final ThemeMode themeMode;

  const SetThemeRequested(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}
