class AppConstants {
  static const String appName = 'Meal Manager';

  // Firestore Collections
  static const String collectionUsers = 'users';
  static const String collectionMesses = 'messes';
  static const String collectionMembers = 'members';
  static const String collectionMealEntries = 'mealEntries';
  static const String collectionGroceryEntries = 'groceryEntries';
  static const String collectionDeposits = 'deposits';
  static const String collectionSettlements = 'settlements';

  // Default Settings
  static const int defaultMealCutoffHour = 22; // 10:00 PM
  static const String defaultCurrency = '৳';
  static const String defaultLocale = 'en';

  // Cloud Functions REST API & Web Push
  static const String apiBaseUrl = 'https://us-central1-meal-manager-844f5.cloudfunctions.net/api';
  static const String webVapidKey = 'BKv1DA3arlJMA9LjJoeEX1DOufNWY6jJuDFj5tNsUrstYNEcThjGjHAMtLtnbkbe_--LrhQqwDXYD0wbr99gJVM';

  // SharedPreferences Keys
  static const String keyThemeMode = 'pref_theme_mode';
  static const String keyLocale = 'pref_locale';
  static const String keyActiveMessId = 'pref_active_mess_id';
}
