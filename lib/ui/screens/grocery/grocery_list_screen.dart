import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/mess/mess_bloc.dart';
import '../../../blocs/mess/mess_state.dart';
import '../../../blocs/grocery/grocery_bloc.dart';
import '../../../blocs/grocery/grocery_state.dart';
import '../../../core/extensions.dart';
import '../../../data/repositories/grocery_repository.dart';
import '../../../data/repositories/deposit_repository.dart';
import '../../../models/grocery_entry.dart';
import '../../../models/deposit.dart';
import 'add_grocery_screen.dart';
import 'grocery_details_modal.dart';

class GroceryListScreen extends StatelessWidget {
  final String messId;
  final String monthStr;

  const GroceryListScreen({
    super.key,
    required this.messId,
    required this.monthStr,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final authState = context.watch<AuthBloc>().state;
    final currentUserId =
        authState is Authenticated ? authState.user.uid : '';

    final messState = context.watch<MessBloc>().state;
    bool isManager = false;
    if (messState is MessLoaded) {
      isManager = (messState.mess.currentManagerId == currentUserId);
    }

    final groceryRepo = context.read<GroceryRepository>();

    return BlocBuilder<GroceryBloc, GroceryState>(
      builder: (context, state) {
        if (state is GroceryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<GroceryEntry> entries = [];
        if (state is GroceryLoaded) {
          entries = state.entries;
        }

        // Only approved entries count towards total
        final approvedTotal = entries
            .where((e) => e.status == 'approved')
            .fold<double>(0.0, (sum, e) => sum + e.amount);

        final depositRepo = context.read<DepositRepository>();

        return StreamBuilder<List<Deposit>>(
          stream: depositRepo.watchMonthlyDeposits(
            messId: messId,
            monthPrefix: monthStr,
          ),
          builder: (context, depSnap) {
            final deposits = depSnap.data ?? [];
            final totalDeposits = deposits
                .where((d) => d.status == 'approved')
                .fold<double>(0.0, (sum, d) => sum + d.amount);
            final remainingBalance = totalDeposits - approvedTotal;

            return Scaffold(
              body: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: theme.colorScheme.primaryContainer,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.totalGrocery,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              approvedTotal.toCurrency(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Total Deposits',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8))),
                                const SizedBox(height: 2),
                                Text(totalDeposits.toCurrency(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Remaining Cash',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8))),
                                const SizedBox(height: 2),
                                Text(
                                  remainingBalance.toCurrency(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: remainingBalance >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Text(
                          'No grocery entries logged yet.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final item = entries[index];
                          final isPending = (item.status == 'pending');
                          final isRejected = (item.status == 'rejected');

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: ListTile(
                              onTap: () => GroceryDetailsModal.show(
                                context,
                                messId: messId,
                                entry: item,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: isPending
                                    ? theme.colorScheme.tertiaryContainer
                                    : isRejected
                                        ? theme.colorScheme.errorContainer
                                        : theme.colorScheme.primaryContainer,
                                child: Icon(
                                  isPending
                                      ? Icons.hourglass_top_rounded
                                      : isRejected
                                          ? Icons.block_rounded
                                          : Icons.shopping_bag_outlined,
                                ),
                              ),
                              title: Text(
                                item.description,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.purchaserName} • ${item.date}',
                                  ),
                                  if (isPending)
                                    const Text(
                                      '⏳ Pending Manager Approval',
                                      style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    )
                                  else if (isRejected)
                                    const Text(
                                      '❌ Rejected by Manager',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.amount.toCurrency(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isRejected
                                          ? Colors.grey
                                          : theme.colorScheme.primary,
                                    ),
                                  ),
                                  if (isManager && isPending) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green,
                                      ),
                                      tooltip: 'Approve Grocery',
                                      onPressed: () async {
                                        await groceryRepo.updateGroceryStatus(
                                          messId: messId,
                                          entryId: item.id,
                                          status: 'approved',
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Reject Grocery',
                                      onPressed: () async {
                                        await groceryRepo.updateGroceryStatus(
                                          messId: messId,
                                          entryId: item.id,
                                          status: 'rejected',
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddGroceryScreen(messId: messId),
                ),
              );
            },
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: Text(l10n.addGrocery),
          ),
        );
      },
    );
  },
);
  }
}
