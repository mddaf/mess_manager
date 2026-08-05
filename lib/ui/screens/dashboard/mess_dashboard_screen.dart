import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/extensions.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/mess/mess_bloc.dart';
import '../../../blocs/mess/mess_event.dart';
import '../../../blocs/mess/mess_state.dart';
import '../../../blocs/meal/meal_bloc.dart';
import '../../../blocs/meal/meal_event.dart';
import '../../../blocs/meal/meal_state.dart';
import '../../../blocs/grocery/grocery_bloc.dart';
import '../../../blocs/grocery/grocery_state.dart';
import '../../../data/repositories/deposit_repository.dart';
import '../../../data/repositories/mess_repository.dart';
import '../../../models/deposit.dart';
import '../../../models/grocery_entry.dart';
import '../../../models/meal_entry.dart';
import '../../../models/member.dart';
import '../../../models/mess.dart';
import '../settlement/archived_months_screen.dart';

class MessDashboardScreen extends StatefulWidget {
  final String messId;

  const MessDashboardScreen({super.key, required this.messId});

  @override
  State<MessDashboardScreen> createState() => _MessDashboardScreenState();
}

class _MessDashboardScreenState extends State<MessDashboardScreen> {
  bool _openingMonth = false;

  Future<void> _handleOpenNewMonth(Mess mess) async {
    final now = DateTime.now();
    final currentMonth = mess.activeMonth.isNotEmpty
        ? mess.activeMonth
        : DateFormat('yyyy-MM').format(now);

    final currentMonthDate = DateFormat('yyyy-MM').parse(currentMonth);
    final nextMonthDate = DateTime(currentMonthDate.year, currentMonthDate.month + 1);
    final nextMonth = DateFormat('yyyy-MM').format(nextMonthDate);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.calendar_month_rounded, size: 40, color: Colors.indigo),
        title: Text('Open New Month ($nextMonth)'),
        content: Text(
          'This will settle the current month ($currentMonth), calculate final meal rates, '
          'archive the monthly member details in tabular form, and carry forward any unpaid dues to $nextMonth.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm & Open New Month'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _openingMonth = true);
      try {
        final repo = context.read<MessRepository>();
        await repo.openNewMonth(
          messId: widget.messId,
          currentMonth: currentMonth,
          nextMonth: nextMonth,
        );

        if (mounted) {
          context.read<MessBloc>().add(WatchMessRequested(widget.messId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 $currentMonth settled! New month ($nextMonth) opened. Unpaid dues carried forward.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _openingMonth = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.uid : '';

    final messState = context.watch<MessBloc>().state;
    final mealState = context.watch<MealBloc>().state;
    final groceryState = context.watch<GroceryBloc>().state;
    final depositRepo = context.read<DepositRepository>();

    if (messState is! MessLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final mess = messState.mess;
    final members = messState.members;
    final isManager = (mess.currentManagerId == currentUserId);

    final currentMonthStr = mess.activeMonth.isNotEmpty
        ? mess.activeMonth
        : DateFormat('yyyy-MM').format(DateTime.now());

    final currentMember = members.firstWhere(
      (m) => m.userId == currentUserId,
      orElse: () => Member(id: currentUserId, userId: currentUserId, name: '', email: ''),
    );

    // Stream Monthly Deposits directly from DepositRepository
    return StreamBuilder<List<Deposit>>(
      stream: depositRepo.watchMonthlyDeposits(
        messId: widget.messId,
        monthPrefix: currentMonthStr,
      ),
      builder: (context, depositSnapshot) {
        final deposits = depositSnapshot.data ?? [];
        final approvedDeposits = deposits.where((d) => d.status == 'approved').toList();

        final double myDeposits = approvedDeposits
            .where((d) => d.memberId == currentUserId)
            .fold(0.0, (sum, d) => sum + d.amount);

        // Calculate Grocery Metrics
        List<GroceryEntry> groceries = [];
        if (groceryState is GroceryLoaded) {
          groceries = groceryState.entries.where((g) => g.status == 'approved').toList();
        }
        final double totalGrocerySpend = groceries.fold(0.0, (sum, g) => sum + g.amount);

        final myGroceries = groceries.where((g) => g.purchasedBy == currentUserId).toList();
        final double myGrocerySpend = myGroceries.fold(0.0, (sum, g) => sum + g.amount);

        // Calculate Meal Metrics
        double totalMessMeals = 0.0;
        double myMeals = 0.0;
        MealEntry? myTodayMeal;
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

        if (mealState is MealLoaded) {
          totalMessMeals = mealState.entries.fold(0.0, (sum, m) => sum + m.totalMealsToday);
          myMeals = mealState.entries
              .where((m) => m.memberId == currentUserId)
              .fold(0.0, (sum, m) => sum + m.totalMealsToday);

          try {
            myTodayMeal = mealState.entries.firstWhere(
              (m) => m.memberId == currentUserId && m.date == todayStr,
            );
          } catch (_) {}
        }

        final double mealRate = totalMessMeals > 0 ? totalGrocerySpend / totalMessMeals : 0.0;
        final double myMealCost = myMeals * mealRate;
        final double openingDues = currentMember.openingDues;

        // My Current Net Balance = Deposit - Cost - Opening Dues
        final double myNetBalance = myDeposits - myMealCost - openingDues;
        final bool hasDues = (myNetBalance < 0 || openingDues > 0);

        return RefreshIndicator(
          onRefresh: () async {
            context.read<MessBloc>().add(WatchMessRequested(widget.messId));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Active Month & Manager Header Card ────────────────────
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded,
                                        size: 18, color: theme.colorScheme.onPrimaryContainer),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ACTIVE MONTH',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                        color: theme.colorScheme.onPrimaryContainer
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentMonthStr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            if (isManager)
                              ElevatedButton.icon(
                                onPressed: _openingMonth
                                    ? null
                                    : () => _handleOpenNewMonth(mess),
                                icon: _openingMonth
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.arrow_forward_rounded, size: 18),
                                label: const Text('Open New Month'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Logged-In User Personal Cards Grid ────────────────────
                Text(
                  'Personal Overview',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    // Net Balance Card
                    Expanded(
                      child: _DashboardCard(
                        title: 'Net Balance',
                        value: myNetBalance.toCurrency(),
                        badgeText: hasDues ? 'Dues 🔴' : 'Surplus 🟢',
                        badgeColor: hasDues ? Colors.red.shade100 : Colors.green.shade100,
                        badgeTextColor: hasDues ? Colors.red.shade900 : Colors.green.shade900,
                        subtitle: openingDues > 0
                            ? 'Carried Dues: ৳${openingDues.toStringAsFixed(0)}'
                            : null,
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: hasDues ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Total Deposit Card
                    Expanded(
                      child: _DashboardCard(
                        title: 'My Deposits',
                        value: myDeposits.toCurrency(),
                        subtitle: 'Approved payments',
                        icon: Icons.savings_rounded,
                        iconColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    // My Meal Count Card
                    Expanded(
                      child: _DashboardCard(
                        title: 'My Meals',
                        value: '${myMeals.toStringAsFixed(1)} meals',
                        subtitle: 'Cost: ৳${myMealCost.toStringAsFixed(0)}',
                        icon: Icons.restaurant_rounded,
                        iconColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // My Bazar Count Card
                    Expanded(
                      child: _DashboardCard(
                        title: 'My Bazar',
                        value: '${myGroceries.length} trips',
                        subtitle: 'Spent: ৳${myGrocerySpend.toStringAsFixed(0)}',
                        icon: Icons.shopping_bag_rounded,
                        iconColor: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Today's Quick Check-in Card ───────────────────────────
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.touch_app_rounded, color: Colors.deepOrange),
                                const SizedBox(width: 8),
                                Text(
                                  "Today's Quick Check-in ($todayStr)",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            Text(
                              myTodayMeal != null
                                  ? '${myTodayMeal.totalMealsToday.toStringAsFixed(1)} meals'
                                  : '0 meals',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _QuickMealChip(
                              label: 'Breakfast 🍳',
                              selected: (myTodayMeal?.breakfast ?? 0.0) > 0,
                              onTap: () => _toggleMeal(
                                currentUserId,
                                todayStr,
                                'breakfast',
                                myTodayMeal?.breakfast ?? 0.0,
                              ),
                            ),
                            _QuickMealChip(
                              label: 'Lunch 🍲',
                              selected: (myTodayMeal?.lunch ?? 0.0) > 0,
                              onTap: () => _toggleMeal(
                                currentUserId,
                                todayStr,
                                'lunch',
                                myTodayMeal?.lunch ?? 0.0,
                              ),
                            ),
                            _QuickMealChip(
                              label: 'Dinner 🍛',
                              selected: (myTodayMeal?.dinner ?? 0.0) > 0,
                              onTap: () => _toggleMeal(
                                currentUserId,
                                todayStr,
                                'dinner',
                                myTodayMeal?.dinner ?? 0.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Whole Mess Overview Section ───────────────────────────
                Text(
                  'Mess Whole Overview',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Meal Rate',
                        value: mealRate.toCurrency(),
                        icon: Icons.pie_chart_rounded,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Mess Bazar',
                        value: totalGrocerySpend.toCurrency(),
                        icon: Icons.store_rounded,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Total Meals',
                        value: totalMessMeals.toStringAsFixed(0),
                        icon: Icons.restaurant_menu_rounded,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Members Tabular Overview Table ────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Members Report Tabular View',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => ArchivedMonthsScreen(
                              messId: widget.messId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.table_chart_rounded, size: 16),
                      label: const Text('Archived Months'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowHeight: 44,
                      columns: const [
                        DataColumn(label: Text('Member', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Meals', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Deposit', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Dues', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: members.where((m) => m.status == 'approved').map((m) {
                        double memberMeals = 0.0;
                        if (mealState is MealLoaded) {
                          memberMeals = mealState.entries
                              .where((e) => e.memberId == m.userId)
                              .fold(0.0, (sum, e) => sum + e.totalMealsToday);
                        }

                        final double memberDeposit = approvedDeposits
                            .where((d) => d.memberId == m.userId)
                            .fold(0.0, (sum, d) => sum + d.amount);

                        final cost = memberMeals * mealRate;
                        final netBal = memberDeposit - cost - m.openingDues;
                        final isCurrent = (m.userId == currentUserId);

                        return DataRow(
                          selected: isCurrent,
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    child: Text(
                                      m.name.isNotEmpty ? m.name[0].toUpperCase() : 'M',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    m.name + (isCurrent ? ' (You)' : ''),
                                    style: TextStyle(
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(memberMeals.toStringAsFixed(1))),
                            DataCell(Text(memberDeposit.toCurrency())),
                            DataCell(
                              Text(
                                m.openingDues > 0 ? '৳${m.openingDues.toStringAsFixed(0)}' : '-',
                                style: TextStyle(
                                  color: m.openingDues > 0 ? Colors.red : Colors.grey,
                                  fontWeight: m.openingDues > 0 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: netBal >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  netBal.toCurrency(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: netBal >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleMeal(String userId, String dateStr, String mealType, double currentVal) {
    context.read<MealBloc>().add(
          ToggleMealRequested(
            messId: widget.messId,
            memberId: userId,
            date: dateStr,
            mealType: mealType,
            currentVal: currentVal,
          ),
        );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final IconData icon;
  final Color iconColor;

  const _DashboardCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 24),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickMealChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _QuickMealChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      selectedColor: Colors.deepOrange.shade100,
      checkmarkColor: Colors.deepOrange.shade900,
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? Colors.deepOrange.shade900 : Colors.black87,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
