import 'package:equatable/equatable.dart';

abstract class MealEvent extends Equatable {
  const MealEvent();

  @override
  List<Object?> get props => [];
}

class WatchMealsForDateRequested extends MealEvent {
  final String messId;
  final String date;

  const WatchMealsForDateRequested({required this.messId, required this.date});

  @override
  List<Object?> get props => [messId, date];
}

class ToggleMealRequested extends MealEvent {
  final String messId;
  final String memberId;
  final String date;
  final String mealType; // breakfast, lunch, dinner
  final double currentVal;

  const ToggleMealRequested({
    required this.messId,
    required this.memberId,
    required this.date,
    required this.mealType,
    required this.currentVal,
  });

  @override
  List<Object?> get props => [messId, memberId, date, mealType, currentVal];
}

class LockMealsRequested extends MealEvent {
  final String messId;
  final String date;
  final bool locked;

  const LockMealsRequested({
    required this.messId,
    required this.date,
    required this.locked,
  });

  @override
  List<Object?> get props => [messId, date, locked];
}
