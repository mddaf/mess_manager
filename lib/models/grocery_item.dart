import 'package:freezed_annotation/freezed_annotation.dart';

part 'grocery_item.freezed.dart';
part 'grocery_item.g.dart';

@freezed
abstract class GroceryItem with _$GroceryItem {
  const factory GroceryItem({
    required String name,
    @Default(1.0) double quantity,
    @Default('kg') String unit,
    required double price,
  }) = _GroceryItem;

  factory GroceryItem.fromJson(Map<String, dynamic> json) =>
      _$GroceryItemFromJson(json);
}
