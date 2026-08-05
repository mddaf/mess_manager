import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../../blocs/settlement/settlement_bloc.dart';
import '../../../blocs/settlement/settlement_event.dart';
import '../../../blocs/settlement/settlement_state.dart';
import '../../../core/extensions.dart';
import '../../../data/repositories/settlement_repository.dart';
import '../../../models/settlement.dart';
import '../../widgets/spending_chart.dart';

class SettlementScreen extends StatelessWidget {
  final String messId;
  final String monthStr;

  const SettlementScreen({
    super.key,
    required this.messId,
    required this.monthStr,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settlementRepo = context.read<SettlementRepository>();

    return BlocListener<SettlementBloc, SettlementState>(
      listener: (context, state) {
        if (state is SettlementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is SettlementLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settlement calculated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: StreamBuilder<Settlement?>(
        stream: settlementRepo.watchSettlement(messId: messId, month: monthStr),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final settlement = snapshot.data;

          if (settlement == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          size: 56,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Settlement Calculated',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Calculate monthly meal rate, total groceries, and individual member balances for $monthStr.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<SettlementBloc, SettlementState>(
                          builder: (context, blocState) {
                            final isLoading = blocState is SettlementLoading;
                            return ElevatedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context.read<SettlementBloc>().add(
                                            CalculateSettlementRequested(
                                              messId: messId,
                                              month: monthStr,
                                            ),
                                          );
                                    },
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.calculate_rounded),
                              label: Text(l10n.calculateSettlement),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final balances = settlement.memberBalances;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          '${l10n.settlement}: $monthStr',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(l10n.totalGrocery,
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  settlement.totalGroceryCost.toCurrency(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(l10n.totalMeals,
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  settlement.totalMeals.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(l10n.mealRate,
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  settlement.mealRate.toCurrency(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (balances.isNotEmpty) ...[
                  Text(
                    'Spending Breakdown (Pie Chart)',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SpendingChart(
                    memberBalances: balances,
                    chartType: SpendingChartType.pie,
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  l10n.whoOwesWhom,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                balances.isEmpty
                    ? Center(
                        child: Text(
                          'No member balances available.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: balances.length,
                        itemBuilder: (context, index) {
                          final b = balances[index];
                          final isPositive = b.balance >= 0;

                          return Card(
                            child: ListTile(
                              title: Text(
                                b.memberName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${l10n.totalMeals}: ${b.totalMeals.toStringAsFixed(1)} • Cost: ৳ ${b.totalCost.toStringAsFixed(0)} • Deposit: ৳ ${b.totalDeposit.toStringAsFixed(0)}',
                              ),
                              trailing: Text(
                                '${isPositive ? '+' : ''}৳ ${b.balance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isPositive ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 20),
                BlocBuilder<SettlementBloc, SettlementState>(
                  builder: (context, blocState) {
                    final isLoading = blocState is SettlementLoading;
                    return ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<SettlementBloc>().add(
                                    CalculateSettlementRequested(
                                      messId: messId,
                                      month: monthStr,
                                    ),
                                  );
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: Text('Recalculate Settlement'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
