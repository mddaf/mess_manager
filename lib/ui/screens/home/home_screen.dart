import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/meal/meal_bloc.dart';
import '../../../blocs/meal/meal_event.dart';
import '../../../blocs/grocery/grocery_bloc.dart';
import '../../../blocs/grocery/grocery_event.dart';
import '../../../blocs/mess/mess_bloc.dart';
import '../../../blocs/mess/mess_event.dart';
import '../../../blocs/settlement/settlement_bloc.dart';
import '../../../blocs/settlement/settlement_event.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/theme_toggle.dart';
import '../meals/meal_checkin_screen.dart';
import '../grocery/grocery_list_screen.dart';
import '../deposits/deposit_screen.dart';
import '../mess/mess_profile_screen.dart';
import '../dashboard/mess_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final String messId;

  const HomeScreen({super.key, required this.messId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final String _currentDateStr;
  late final String _currentMonthStr;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentDateStr = DateFormat('yyyy-MM-dd').format(now);
    _currentMonthStr = DateFormat('yyyy-MM').format(now);

    // Watch the mess itself (members, mess details)
    context.read<MessBloc>().add(WatchMessRequested(widget.messId));

    // Start watching real Firestore data for this mess
    context.read<MealBloc>().add(
          WatchMealsForDateRequested(messId: widget.messId, date: _currentDateStr),
        );
    context.read<GroceryBloc>().add(
          WatchMonthlyGroceriesRequested(
            messId: widget.messId,
            monthPrefix: _currentMonthStr,
          ),
        );
    context.read<SettlementBloc>().add(
          WatchSettlementRequested(messId: widget.messId, month: _currentMonthStr),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      MessDashboardScreen(messId: widget.messId),
      MealCheckinScreen(messId: widget.messId, dateStr: _currentDateStr),
      GroceryListScreen(messId: widget.messId, monthStr: _currentMonthStr),
      DepositScreen(messId: widget.messId, monthStr: _currentMonthStr),
      MessProfileScreen(messId: widget.messId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          const LanguageSwitcherButton(),
          const ThemeToggleIconButton(),
          // User profile avatar button
          IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            tooltip: 'My Profile',
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Bazar',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Deposits',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_work_outlined),
            selectedIcon: Icon(Icons.home_work),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
