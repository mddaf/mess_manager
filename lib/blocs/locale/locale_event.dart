import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocaleRequested extends LocaleEvent {}

class ChangeLocaleRequested extends LocaleEvent {
  final Locale locale;

  const ChangeLocaleRequested(this.locale);

  @override
  List<Object?> get props => [locale];
}
