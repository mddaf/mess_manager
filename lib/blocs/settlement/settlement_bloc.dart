import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/settlement_repository.dart';
import '../../models/settlement.dart';
import 'settlement_event.dart';
import 'settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  final SettlementRepository _settlementRepository;

  SettlementBloc({required SettlementRepository settlementRepository})
      : _settlementRepository = settlementRepository,
        super(SettlementInitial()) {
    on<WatchSettlementRequested>(_onWatchSettlement);
    on<CalculateSettlementRequested>(_onCalculateSettlement);
    on<MarkSettledRequested>(_onMarkSettled);
  }

  Future<void> _onWatchSettlement(
    WatchSettlementRequested event,
    Emitter<SettlementState> emit,
  ) async {
    emit(SettlementLoading());

    await emit.forEach<Settlement?>(
      _settlementRepository.watchSettlement(
        messId: event.messId,
        month: event.month,
      ),
      onData: (settlement) {
        if (settlement != null) {
          return SettlementLoaded(settlement);
        } else {
          return SettlementEmpty(event.month);
        }
      },
      onError: (error, stackTrace) => SettlementError(error.toString()),
    );
  }

  Future<void> _onCalculateSettlement(
    CalculateSettlementRequested event,
    Emitter<SettlementState> emit,
  ) async {
    emit(SettlementLoading());
    try {
      final settlement = await _settlementRepository.calculateSettlement(
        messId: event.messId,
        month: event.month,
      );
      emit(SettlementLoaded(settlement));
    } catch (e) {
      emit(SettlementError(e.toString()));
    }
  }

  Future<void> _onMarkSettled(
    MarkSettledRequested event,
    Emitter<SettlementState> emit,
  ) async {
    try {
      await _settlementRepository.markSettled(
        messId: event.messId,
        month: event.month,
      );
    } catch (e) {
      emit(SettlementError(e.toString()));
    }
  }
}
