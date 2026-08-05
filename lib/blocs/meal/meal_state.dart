import 'package:equatable/equatable.dart';
import '../../models/meal_entry.dart';

abstract class MealState extends Equatable {
  const MealState();

  @override
  List<Object?> get props => [];
}

class MealInitial extends MealState {}

class MealLoading extends MealState {}

class MealLoaded extends MealState {
  final String date;
  final List<MealEntry> entries;
  final double totalMealsToday;

  const MealLoaded({
    required this.date,
    required this.entries,
    required this.totalMealsToday,
  });

  @override
  List<Object?> get props => [date, entries, totalMealsToday];
}

class MealError extends MealState {
  final String message;

  const MealError(this.message);

  @override
  List<Object?> get props => [message];
}
