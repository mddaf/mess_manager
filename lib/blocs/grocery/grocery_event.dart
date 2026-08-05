import 'package:equatable/equatable.dart';
import '../../models/grocery_entry.dart';

abstract class GroceryEvent extends Equatable {
  const GroceryEvent();

  @override
  List<Object?> get props => [];
}

class WatchMonthlyGroceriesRequested extends GroceryEvent {
  final String messId;
  final String monthPrefix;

  const WatchMonthlyGroceriesRequested({
    required this.messId,
    required this.monthPrefix,
  });

  @override
  List<Object?> get props => [messId, monthPrefix];
}

class ScanReceiptRequested extends GroceryEvent {
  final String imagePath;

  const ScanReceiptRequested(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class AddGroceryRequested extends GroceryEvent {
  final String messId;
  final GroceryEntry entry;
  final String? receiptImagePath;

  const AddGroceryRequested({
    required this.messId,
    required this.entry,
    this.receiptImagePath,
  });

  @override
  List<Object?> get props => [messId, entry, receiptImagePath];
}

class DeleteGroceryRequested extends GroceryEvent {
  final String messId;
  final String entryId;

  const DeleteGroceryRequested({
    required this.messId,
    required this.entryId,
  });

  @override
  List<Object?> get props => [messId, entryId];
}
