import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/enums.dart';
import '../../data/repositories/meal_repository.dart';
import '../../models/meal_entry.dart';
import 'meal_event.dart';
import 'meal_state.dart';

class MealBloc extends Bloc<MealEvent, MealState> {
  final MealRepository _mealRepository;

  MealBloc({required MealRepository mealRepository})
      : _mealRepository = mealRepository,
        super(MealInitial()) {
    on<WatchMealsForDateRequested>(_onWatchMealsForDate);
    on<ToggleMealRequested>(_onToggleMeal);
    on<LockMealsRequested>(_onLockMeals);
  }

  Future<void> _onWatchMealsForDate(
    WatchMealsForDateRequested event,
    Emitter<MealState> emit,
  ) async {
    emit(MealLoading());

    await emit.forEach<List<MealEntry>>(
      _mealRepository.watchMealsForDate(
        messId: event.messId,
        date: event.date,
      ),
      onData: (entries) {
        double total = 0.0;
        for (final entry in entries) {
          total += entry.totalMealsToday;
        }
        return MealLoaded(
          date: event.date,
          entries: entries,
          totalMealsToday: total,
        );
      },
      onError: (error, stackTrace) => MealError(error.toString()),
    );
  }

  Future<void> _onToggleMeal(
    ToggleMealRequested event,
    Emitter<MealState> emit,
  ) async {
    final nextVal = MealValue.fromDouble(event.currentVal).toggleNext().value;

    final currentState = state;
    MealEntry? existing;
    if (currentState is MealLoaded) {
      existing = currentState.entries.firstWhere(
        (e) => e.memberId == event.memberId,
        orElse: () => MealEntry(
          id: '${event.memberId}_${event.date}',
          memberId: event.memberId,
          date: event.date,
        ),
      );
    } else {
      existing = MealEntry(
        id: '${event.memberId}_${event.date}',
        memberId: event.memberId,
        date: event.date,
      );
    }

    double b = existing.breakfast;
    double l = existing.lunch;
    double d = existing.dinner;

    if (event.mealType == 'breakfast') b = nextVal;
    if (event.mealType == 'lunch') l = nextVal;
    if (event.mealType == 'dinner') d = nextVal;

    await _mealRepository.updateMealEntry(
      messId: event.messId,
      memberId: event.memberId,
      date: event.date,
      breakfast: b,
      lunch: l,
      dinner: d,
    );
  }

  Future<void> _onLockMeals(
    LockMealsRequested event,
    Emitter<MealState> emit,
  ) async {
    await _mealRepository.setLockStatusForDate(
      messId: event.messId,
      date: event.date,
      locked: event.locked,
    );
  }
}
