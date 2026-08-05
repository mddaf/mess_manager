import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/extensions.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
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

  Future<void> _showAddDepositDialog(
      BuildContext context, List<Member> members, bool isManager, String currentUserId) async {
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No members in this mess yet.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: 'Cash paid to manager');

    // Default to current user for regular members
    final defaultMember = members.firstWhere(
      (m) => m.userId == currentUserId,
      orElse: () => members.first,
    );

    String selectedMemberId = defaultMember.userId;
    String selectedMemberName = defaultMember.name;

    final depositRepo = context.read<DepositRepository>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(isManager ? 'Add Approved Deposit' : 'Request Deposit'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isManager)
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
                        )
                      else
                        TextFormField(
                          initialValue: selectedMemberName,
                          decoration: const InputDecoration(labelText: 'Member'),
                          readOnly: true,
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
                  child: Text(isManager ? 'Save Deposit' : 'Submit Request'),
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
      final status = isManager ? 'approved' : 'pending';

      final deposit = Deposit(
        id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
        memberId: selectedMemberId,
        memberName: selectedMemberName,
        amount: amount,
        date: dateStr,
        note: noteController.text.trim(),
        status: status,
        createdAt: DateTime.now(),
      );

      await depositRepo.addDeposit(messId: messId, deposit: deposit);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isManager
                  ? 'Deposit added successfully!'
                  : 'Deposit requested! Waiting for Manager approval.',
            ),
            backgroundColor: isManager ? Colors.green : Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final depositRepo = context.read<DepositRepository>();

    final authState = context.watch<AuthBloc>().state;
    final currentUserId =
        authState is Authenticated ? authState.user.uid : '';

    final messState = context.watch<MessBloc>().state;
    List<Member> members = [];
    bool isManager = false;
    if (messState is MessLoaded) {
      members = messState.members;
      isManager = (messState.mess.currentManagerId == currentUserId);
    }

    return StreamBuilder<List<Deposit>>(
      stream: depositRepo.watchMonthlyDeposits(
        messId: messId,
        monthPrefix: monthStr,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final deposits = snapshot.data ?? [];
        final approvedTotal = deposits
            .where((d) => d.status == 'approved')
            .fold<double>(0.0, (sum, item) => sum + item.amount);

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
                      approvedTotal.toCurrency(),
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
                          final isPending = (dep.status == 'pending');
                          final isRejected = (dep.status == 'rejected');

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: ListTile(
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
                                          : Icons.attach_money_rounded,
                                ),
                              ),
                              title: Text(
                                dep.memberName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${dep.date} • ${dep.note}'),
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
                                    dep.amount.toCurrency(),
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
                                      tooltip: 'Approve Deposit',
                                      onPressed: () async {
                                        await depositRepo.updateDepositStatus(
                                          messId: messId,
                                          depositId: dep.id,
                                          memberId: dep.memberId,
                                          amount: dep.amount,
                                          newStatus: 'approved',
                                          previousStatus: dep.status,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Reject Deposit',
                                      onPressed: () async {
                                        await depositRepo.updateDepositStatus(
                                          messId: messId,
                                          depositId: dep.id,
                                          memberId: dep.memberId,
                                          amount: dep.amount,
                                          newStatus: 'rejected',
                                          previousStatus: dep.status,
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
            onPressed: () =>
                _showAddDepositDialog(context, members, isManager, currentUserId),
            icon: const Icon(Icons.add_card_rounded),
            label: Text(l10n.addDeposit),
          ),
        );
      },
    );
  }
}
