import 'package:equatable/equatable.dart';

abstract class SettlementEvent extends Equatable {
  const SettlementEvent();

  @override
  List<Object?> get props => [];
}

class WatchSettlementRequested extends SettlementEvent {
  final String messId;
  final String month;

  const WatchSettlementRequested({required this.messId, required this.month});

  @override
  List<Object?> get props => [messId, month];
}

class CalculateSettlementRequested extends SettlementEvent {
  final String messId;
  final String month;

  const CalculateSettlementRequested({required this.messId, required this.month});

  @override
  List<Object?> get props => [messId, month];
}

class MarkSettledRequested extends SettlementEvent {
  final String messId;
  final String month;

  const MarkSettledRequested({required this.messId, required this.month});

  @override
  List<Object?> get props => [messId, month];
}
