import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/extensions.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/mess/mess_bloc.dart';
import '../../../blocs/mess/mess_event.dart';
import '../../../blocs/mess/mess_state.dart';
import '../../../data/repositories/settlement_repository.dart';
import '../../../models/settlement.dart';

class ArchivedMonthsScreen extends StatefulWidget {
  final String messId;

  const ArchivedMonthsScreen({super.key, required this.messId});

  @override
  State<ArchivedMonthsScreen> createState() => _ArchivedMonthsScreenState();
}

class _ArchivedMonthsScreenState extends State<ArchivedMonthsScreen> {
  String? _selectedMonth;

  Future<void> _handleDeleteArchivedMonth({
    required BuildContext context,
    required String month,
    required bool isAdmin,
    required bool isManager,
  }) async {
    if (!isAdmin && isManager) {
      // Non-admin Manager requires Admin Approval
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.admin_panel_settings_rounded, size: 40, color: Colors.orange),
          title: const Text('Admin Approval Required'),
          content: Text(
            'Re-opening / deleting archived month ($month) requires approval from a Mess Admin. '
            'Please ask an Admin to perform or approve this action.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Only an Admin or Manager can re-open an archived month.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.restore_page_rounded, size: 40, color: Colors.red),
        title: Text('Re-open Month ($month)?'),
        content: Text(
          'Deleting this archived settlement will make $month the ACTIVE month again, '
          'allowing members and managers to adjust entries and recalculate.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Re-open Month'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repo = context.read<SettlementRepository>();
        await repo.deleteArchivedMonth(messId: widget.messId, month: month);

        if (context.mounted) {
          context.read<MessBloc>().add(WatchMessRequested(widget.messId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Month $month has been re-opened as the active month!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.uid : '';

    final messState = context.watch<MessBloc>().state;
    bool isAdmin = false;
    bool isManager = false;

    if (messState is MessLoaded) {
      isManager = (messState.mess.currentManagerId == currentUserId);
      final currentMember = messState.members.firstWhere(
        (m) => m.userId == currentUserId,
        orElse: () => messState.members.first,
      );
      isAdmin = (currentMember.role == 'admin');
    }

    final repo = context.read<SettlementRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Monthly Reports'),
      ),
      body: StreamBuilder<List<Settlement>>(
        stream: repo.watchAllSettlements(widget.messId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final settlements = snapshot.data ?? [];

          if (settlements.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'No Archived Months Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When the manager opens a new month, the closed month report will be archived here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: settlements.length,
            itemBuilder: (context, index) {
              final s = settlements[index];
              final isExpanded = (_selectedMonth == s.month);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ExpansionTile(
                  key: Key(s.month),
                  initiallyExpanded: isExpanded || index == 0,
                  onExpansionChanged: (exp) {
                    setState(() {
                      _selectedMonth = exp ? s.month : null;
                    });
                  },
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.archive_rounded, color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    'Archived Month: ${s.month}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    'Meal Rate: ${s.mealRate.toCurrency()} • Total Meals: ${s.totalMeals.toStringAsFixed(0)}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Summary metrics container
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Total Grocery', style: TextStyle(fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text(
                                      s.totalGroceryCost.toCurrency(),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Total Meals', style: TextStyle(fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text(
                                      s.totalMeals.toStringAsFixed(1),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Meal Rate', style: TextStyle(fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text(
                                      s.mealRate.toCurrency(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tabular Format Member Details Table
                          const Text(
                            'Member Monthly Details (Tabular View)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 16,
                              headingRowHeight: 40,
                              columns: const [
                                DataColumn(
                                    label: Text('Member', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Meals', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Deposit', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Net Balance',
                                        style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: s.memberBalances.map((b) {
                                final isPos = b.balance >= 0;
                                return DataRow(
                                  cells: [
                                    DataCell(Text(b.memberName,
                                        style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text(b.totalMeals.toStringAsFixed(1))),
                                    DataCell(Text(b.totalDeposit.toCurrency())),
                                    DataCell(Text(b.totalCost.toCurrency())),
                                    DataCell(
                                      Text(
                                        '${isPos ? '+' : ''}${b.balance.toCurrency()}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isPos ? Colors.green.shade800 : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Manager / Admin Delete Button
                          OutlinedButton.icon(
                            onPressed: () => _handleDeleteArchivedMonth(
                              context: context,
                              month: s.month,
                              isAdmin: isAdmin,
                              isManager: isManager,
                            ),
                            icon: const Icon(Icons.restore_rounded, color: Colors.red),
                            label: Text(
                              isAdmin
                                  ? 'Re-open / Delete Archived Month'
                                  : 'Request Admin to Re-open Month',
                              style: const TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
