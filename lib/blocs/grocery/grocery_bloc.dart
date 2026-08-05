import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/grocery_repository.dart';
import '../../data/services/ocr_service.dart';
import '../../models/grocery_entry.dart';
import 'grocery_event.dart';
import 'grocery_state.dart';

class GroceryBloc extends Bloc<GroceryEvent, GroceryState> {
  final GroceryRepository _groceryRepository;
  final OcrService _ocrService;

  GroceryBloc({
    required GroceryRepository groceryRepository,
    OcrService? ocrService,
  })  : _groceryRepository = groceryRepository,
        _ocrService = ocrService ?? OcrService(),
        super(GroceryInitial()) {
    on<WatchMonthlyGroceriesRequested>(_onWatchMonthlyGroceries);
    on<ScanReceiptRequested>(_onScanReceipt);
    on<AddGroceryRequested>(_onAddGrocery);
    on<DeleteGroceryRequested>(_onDeleteGrocery);
  }

  Future<void> _onWatchMonthlyGroceries(
    WatchMonthlyGroceriesRequested event,
    Emitter<GroceryState> emit,
  ) async {
    emit(GroceryLoading());

    await emit.forEach<List<GroceryEntry>>(
      _groceryRepository.watchMonthlyGroceries(
        messId: event.messId,
        monthPrefix: event.monthPrefix,
      ),
      onData: (entries) {
        double total = 0.0;
        for (final entry in entries) {
          total += entry.amount;
        }
        return GroceryLoaded(
          entries: entries,
          totalGroceryCost: total,
        );
      },
      onError: (error, stackTrace) => GroceryError(error.toString()),
    );
  }

  Future<void> _onScanReceipt(
    ScanReceiptRequested event,
    Emitter<GroceryState> emit,
  ) async {
    final currentState = state;
    if (currentState is GroceryLoaded) {
      emit(currentState.copyWith(isScanning: true));
      final ocrRes = await _ocrService.processReceiptImage(event.imagePath);
      emit(currentState.copyWith(ocrResult: ocrRes, isScanning: false));
    }
  }

  Future<void> _onAddGrocery(
    AddGroceryRequested event,
    Emitter<GroceryState> emit,
  ) async {
    try {
      String? receiptUrl;
      if (event.receiptImagePath != null) {
        receiptUrl = await _groceryRepository.uploadReceiptPhoto(
          messId: event.messId,
          imagePath: event.receiptImagePath!,
        );
      }

      final entryWithReceipt = event.entry.copyWith(receiptUrl: receiptUrl);
      await _groceryRepository.addGroceryEntry(
        messId: event.messId,
        entry: entryWithReceipt,
      );
    } catch (e) {
      emit(GroceryError(e.toString()));
    }
  }

  Future<void> _onDeleteGrocery(
    DeleteGroceryRequested event,
    Emitter<GroceryState> emit,
  ) async {
    try {
      await _groceryRepository.deleteGroceryEntry(
        messId: event.messId,
        entryId: event.entryId,
      );
    } catch (e) {
      emit(GroceryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _ocrService.dispose();
    return super.close();
  }
}
