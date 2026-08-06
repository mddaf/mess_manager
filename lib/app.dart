import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/mess_repository.dart';
import 'data/repositories/meal_repository.dart';
import 'data/repositories/grocery_repository.dart';
import 'data/repositories/deposit_repository.dart';
import 'data/repositories/settlement_repository.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/theme/theme_bloc.dart';
import 'blocs/theme/theme_event.dart';
import 'blocs/theme/theme_state.dart';
import 'blocs/locale/locale_bloc.dart';
import 'blocs/locale/locale_event.dart';
import 'blocs/locale/locale_state.dart';
import 'blocs/mess/mess_bloc.dart';
import 'blocs/meal/meal_bloc.dart';
import 'blocs/grocery/grocery_bloc.dart';
import 'blocs/settlement/settlement_bloc.dart';

import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class MessManagerApp extends StatefulWidget {
  const MessManagerApp({super.key});

  @override
  State<MessManagerApp> createState() => _MessManagerAppState();
}

class _MessManagerAppState extends State<MessManagerApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(
      authRepository: AuthRepository(),
    )..add(AuthCheckRequested());
    // Build router once — it holds a reference to AuthBloc for redirect logic
    _router = buildAppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => MessRepository()),
        RepositoryProvider(create: (_) => MealRepository()),
        RepositoryProvider(create: (_) => GroceryRepository()),
        RepositoryProvider(create: (_) => DepositRepository()),
        RepositoryProvider(create: (_) => SettlementRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider(
            create: (_) => ThemeBloc()..add(LoadThemeRequested()),
          ),
          BlocProvider(
            create: (_) => LocaleBloc()..add(LoadLocaleRequested()),
          ),
          BlocProvider(
            create: (context) => MessBloc(
              messRepository: context.read<MessRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => MealBloc(
              mealRepository: context.read<MealRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => GroceryBloc(
              groceryRepository: context.read<GroceryRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => SettlementBloc(
              settlementRepository: context.read<SettlementRepository>(),
            ),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          bloc: _authBloc,
          listener: (context, state) {
            // Force router to re-evaluate redirect whenever AuthBloc changes
            _router.refresh();
          },
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return BlocBuilder<LocaleBloc, LocaleState>(
                builder: (context, localeState) {
                  return MaterialApp.router(
                    title: 'Meal Manager',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme(),
                    darkTheme: AppTheme.darkTheme(),
                    themeMode: themeState.themeMode,
                    locale: localeState.locale,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('en'),
                      Locale('bn'),
                    ],
                    routerConfig: _router,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
