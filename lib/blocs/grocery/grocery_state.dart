import 'package:equatable/equatable.dart';
import '../../models/grocery_entry.dart';
import '../../data/services/receipt_parser.dart';

abstract class GroceryState extends Equatable {
  const GroceryState();

  @override
  List<Object?> get props => [];
}

class GroceryInitial extends GroceryState {}

class GroceryLoading extends GroceryState {}

class GroceryLoaded extends GroceryState {
  final List<GroceryEntry> entries;
  final double totalGroceryCost;
  final OcrResult? ocrResult;
  final bool isScanning;

  const GroceryLoaded({
    required this.entries,
    required this.totalGroceryCost,
    this.ocrResult,
    this.isScanning = false,
  });

  GroceryLoaded copyWith({
    List<GroceryEntry>? entries,
    double? totalGroceryCost,
    OcrResult? ocrResult,
    bool? isScanning,
  }) {
    return GroceryLoaded(
      entries: entries ?? this.entries,
      totalGroceryCost: totalGroceryCost ?? this.totalGroceryCost,
      ocrResult: ocrResult ?? this.ocrResult,
      isScanning: isScanning ?? this.isScanning,
    );
  }

  @override
  List<Object?> get props => [entries, totalGroceryCost, ocrResult, isScanning];
}

class GroceryError extends GroceryState {
  final String message;

  const GroceryError(this.message);

  @override
  List<Object?> get props => [message];
}
