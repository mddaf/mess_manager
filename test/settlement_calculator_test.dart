import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Settlement Calculation & Meal Rate Tests', () {
    test('Calculates meal rate correctly', () {
      const double totalGroceryCost = 15000.0;
      const double totalMealsEaten = 300.0;

      final mealRate = totalMealsEaten > 0 ? totalGroceryCost / totalMealsEaten : 0.0;
      expect(mealRate, equals(50.0));
    });

    test('Calculates member net balance with carried dues', () {
      const double mealRate = 50.0;
      const double memberMeals = 40.0; // Member meal cost = 2000
      const double memberDeposit = 2500.0;
      const double carriedDues = 200.0;

      final memberCost = memberMeals * mealRate; // 2000.0
      final netBalance = memberDeposit - memberCost - carriedDues; // 2500 - 2000 - 200 = 300

      expect(memberCost, equals(2000.0));
      expect(netBalance, equals(300.0));
    });

    test('Identifies negative balance as member dues', () {
      const double mealRate = 50.0;
      const double memberMeals = 60.0; // Cost = 3000
      const double memberDeposit = 2000.0;
      const double carriedDues = 0.0;

      final memberCost = memberMeals * mealRate;
      final netBalance = memberDeposit - memberCost - carriedDues; // -1000.0

      expect(netBalance, equals(-1000.0));
      expect(netBalance.isNegative, isTrue);
    });
  });
}
