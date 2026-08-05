import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/mess/mess_bloc.dart';
import '../../../blocs/mess/mess_state.dart';
import '../screens/approvals/approvals_dashboard_screen.dart';
import '../screens/settlement/archived_months_screen.dart';
import '../screens/settlement/settlement_screen.dart';

class AppDrawer extends StatelessWidget {
  final String messId;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppDrawer({
    super.key,
    required this.messId,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    final messState = context.watch<MessBloc>().state;
    String messName = 'Meal Manager';
    String activeMonth = '';
    bool isManager = false;

    if (messState is MessLoaded) {
      messName = messState.mess.name;
      activeMonth = messState.mess.activeMonth;
      isManager = (user != null && messState.mess.currentManagerId == user.uid);
    }

    return Drawer(
      child: Column(
        children: [
          // ── Header Drawer Banner ────────────────────────────────────
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            accountName: Text(
              '${user?.name ?? 'Member'} • $messName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                if (activeMonth.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Active Month: $activeMonth',
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'M',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ),

          // ── Drawer Links List ────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard_rounded),
                  title: const Text('Dashboard'),
                  selected: selectedIndex == 0,
                  onTap: () {
                    Navigator.pop(context);
                    onDestinationSelected(0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restaurant_rounded),
                  title: const Text('Meal Check-in (Day Picker)'),
                  selected: selectedIndex == 1,
                  onTap: () {
                    Navigator.pop(context);
                    onDestinationSelected(1);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag_rounded),
                  title: const Text('Grocery & Bazar'),
                  selected: selectedIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    onDestinationSelected(2);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_rounded),
                  title: const Text('Deposits'),
                  selected: selectedIndex == 3,
                  onTap: () {
                    Navigator.pop(context);
                    onDestinationSelected(3);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.bar_chart_rounded),
                  title: const Text('Current Month Settlement'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => SettlementScreen(
                          messId: messId,
                          monthStr: activeMonth,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.archive_rounded),
                  title: const Text('Archived Monthly Reports'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ArchivedMonthsScreen(messId: messId),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.fact_check_rounded, color: Colors.orange),
                  title: const Text('Approvals Dashboard'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isManager ? 'Manager' : 'View',
                      style: TextStyle(fontSize: 10, color: Colors.orange.shade900, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ApprovalsDashboardScreen(messId: messId),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.home_work_rounded),
                  title: const Text('Mess Settings & Profile'),
                  selected: selectedIndex == 4,
                  onTap: () {
                    Navigator.pop(context);
                    onDestinationSelected(4);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle_rounded),
                  title: const Text('My User Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                ),
              ],
            ),
          ),

          // ── Bottom Sign Out Action ───────────────────────────────────
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
