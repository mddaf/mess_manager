import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/extensions.dart';
import '../../../data/repositories/deposit_repository.dart';
import '../../../blocs/mess/mess_bloc.dart';
import '../../../blocs/mess/mess_state.dart';
import '../../../models/deposit.dart';
import '../../../models/member.dart';

class DepositScreen extends StatelessWidget {
  final String messId;
  final String monthStr;

  const DepositScreen({
    super.key,
    required this.messId,
    required this.monthStr,
  });

  Future<void> _showAddDepositDialog(BuildContext context, List<Member> members) async {
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No members in this mess yet.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: 'Cash paid to manager');
    String selectedMemberId = members.first.userId;
    String selectedMemberName = members.first.name;

    final depositRepo = context.read<DepositRepository>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Add Deposit'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedMemberId,
                        decoration: const InputDecoration(labelText: 'Member'),
                        items: members.map((m) {
                          return DropdownMenuItem<String>(
                            value: m.userId,
                            child: Text(m.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedMemberId = val;
                              selectedMemberName = members
                                  .firstWhere((m) => m.userId == val)
                                  .name;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (৳)',
                          prefixIcon: Icon(Icons.attach_money_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter amount';
                          if (double.tryParse(v.trim()) == null) return 'Enter valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note / Payment Method',
                          prefixIcon: Icon(Icons.note_alt_outlined),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter note' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(ctx, true);
                    }
                  },
                  child: const Text('Save Deposit'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final amount = double.parse(amountController.text.trim());
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final deposit = Deposit(
        id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
        memberId: selectedMemberId,
        memberName: selectedMemberName,
        amount: amount,
        date: dateStr,
        note: noteController.text.trim(),
        createdAt: DateTime.now(),
      );

      await depositRepo.addDeposit(messId: messId, deposit: deposit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final messRepo = context.read<DepositRepository>();

    final messState = context.watch<MessBloc>().state;
    List<Member> members = [];
    if (messState is MessLoaded) {
      members = messState.members;
    }

    return StreamBuilder<List<Deposit>>(
      stream: messRepo.watchMonthlyDeposits(
        messId: messId,
        monthPrefix: monthStr,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final deposits = snapshot.data ?? [];
        final totalDeposits = deposits.fold<double>(
          0.0,
          (sum, item) => sum + item.amount,
        );

        return Scaffold(
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: theme.colorScheme.secondaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.deposits,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      totalDeposits.toCurrency(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: deposits.isEmpty
                    ? Center(
                        child: Text(
                          'No deposits logged for $monthStr yet.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: deposits.length,
                        itemBuilder: (context, index) {
                          final dep = deposits[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: const Icon(Icons.attach_money_rounded),
                              ),
                              title: Text(
                                dep.memberName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${dep.date} • ${dep.note}'),
                              trailing: Text(
                                dep.amount.toCurrency(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddDepositDialog(context, members),
            icon: const Icon(Icons.add_card_rounded),
            label: Text(l10n.addDeposit),
          ),
        );
      },
    );
  }
}
