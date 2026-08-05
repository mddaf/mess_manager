import 'package:equatable/equatable.dart';
import '../../models/settlement.dart';

abstract class SettlementState extends Equatable {
  const SettlementState();

  @override
  List<Object?> get props => [];
}

class SettlementInitial extends SettlementState {}

class SettlementLoading extends SettlementState {}

class SettlementLoaded extends SettlementState {
  final Settlement settlement;

  const SettlementLoaded(this.settlement);

  @override
  List<Object?> get props => [settlement];
}

class SettlementEmpty extends SettlementState {
  final String month;

  const SettlementEmpty(this.month);

  @override
  List<Object?> get props => [month];
}

class SettlementError extends SettlementState {
  final String message;

  const SettlementError(this.message);

  @override
  List<Object?> get props => [message];
}
