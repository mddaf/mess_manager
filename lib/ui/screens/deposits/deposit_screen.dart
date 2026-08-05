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

  Future<void> _showAddOrEditDepositDialog(
    BuildContext context, {
    required List<Member> members,
    required bool isManager,
    required String currentUserId,
    Deposit? existingDeposit,
  }) async {
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No members in this mess yet.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      text: existingDeposit != null ? existingDeposit.amount.toStringAsFixed(0) : '',
    );
    final noteController = TextEditingController(
      text: existingDeposit != null
          ? existingDeposit.note
          : (isManager ? 'Direct Deposit' : 'Cash paid to manager'),
    );

    final defaultMember = members.firstWhere(
      (m) => m.userId == (existingDeposit?.memberId ?? currentUserId),
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
              title: Text(
                existingDeposit != null
                    ? (isManager ? 'Edit Deposit' : 'Request Deposit Edit')
                    : (isManager ? 'Add Approved Deposit' : 'Request Deposit'),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isManager && existingDeposit == null) ...[
                        DropdownButtonFormField<String>(
                          value: selectedMemberId,
                          decoration: const InputDecoration(
                            labelText: 'Member',
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                          items: members.map((m) {
                            return DropdownMenuItem(
                              value: m.userId,
                              child: Text(m.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedMemberId = val;
                                selectedMemberName =
                                    members.firstWhere((m) => m.userId == val).name;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (৳)',
                          prefixIcon: Icon(Icons.money_rounded),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter amount';
                          final numVal = double.tryParse(val.trim());
                          if (numVal == null || numVal <= 0) return 'Enter valid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note / Payment Method',
                          prefixIcon: Icon(Icons.note_rounded),
                        ),
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
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(existingDeposit != null ? 'Save' : 'Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && context.mounted) {
      final amount = double.parse(amountController.text.trim());
      final note = noteController.text.trim();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final status = isManager ? 'approved' : 'pending';

      if (existingDeposit != null) {
        // Edit Deposit
        final updated = existingDeposit.copyWith(
          amount: amount,
          note: note,
          status: status,
        );

        await depositRepo.updateDeposit(messId: messId, deposit: updated);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isManager
                    ? 'Deposit updated & saved!'
                    : 'Deposit edit submitted! Waiting for Manager approval.',
              ),
              backgroundColor: isManager ? Colors.green : Colors.orange,
            ),
          );
        }
      } else {
        // Add Deposit
        final deposit = Deposit(
          id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
          memberId: selectedMemberId,
          memberName: selectedMemberName,
          amount: amount,
          date: dateStr,
          note: note,
          status: status,
          createdAt: DateTime.now(),
        );

        await depositRepo.addDeposit(messId: messId, deposit: deposit);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isManager
                    ? 'Deposit added & approved!'
                    : 'Deposit request submitted! Waiting for Manager approval.',
              ),
              backgroundColor: isManager ? Colors.green : Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteDeposit(
    BuildContext context, {
    required Deposit deposit,
    required bool isManager,
    required String currentUserId,
  }) async {
    final depositRepo = context.read<DepositRepository>();

    if (isManager) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Deposit'),
          content: Text('Are you sure you want to delete deposit of ৳${deposit.amount}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        await depositRepo.deleteDeposit(
          messId: messId,
          depositId: deposit.id,
          memberId: deposit.memberId,
          amount: deposit.amount,
          status: deposit.status,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deposit deleted.')),
          );
        }
      }
    } else {
      // Regular Member request deletion approval
      final updated = deposit.copyWith(status: 'pending_delete');
      await depositRepo.updateDeposit(messId: messId, deposit: updated);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deposit deletion request submitted! Waiting for Manager approval.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.uid : '';

    final messState = context.watch<MessBloc>().state;
    List<Member> members = [];
    bool isManager = false;
    if (messState is MessLoaded) {
      members = messState.members.where((m) => m.status == 'approved').toList();
      isManager = (messState.mess.currentManagerId == currentUserId);
    }

    final depositRepo = context.read<DepositRepository>();

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
                          final isPendingDelete = (dep.status == 'pending_delete');
                          final isRejected = (dep.status == 'rejected');
                          final isOwnDeposit = (dep.memberId == currentUserId);
                          final canModify = isManager || isOwnDeposit;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (isPending || isPendingDelete)
                                    ? theme.colorScheme.tertiaryContainer
                                    : isRejected
                                        ? theme.colorScheme.errorContainer
                                        : theme.colorScheme.primaryContainer,
                                child: Icon(
                                  (isPending || isPendingDelete)
                                      ? Icons.hourglass_top_rounded
                                      : isRejected
                                          ? Icons.block_rounded
                                          : Icons.attach_money_rounded,
                                ),
                              ),
                              title: Text(
                                dep.memberName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${dep.date} • ${dep.note}'),
                                  if (isPending)
                                    const Text('⏳ Pending Manager Approval',
                                        style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold))
                                  else if (isPendingDelete)
                                    const Text('⏳ Deletion Requested (Pending Manager Approval)',
                                        style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold))
                                  else if (isRejected)
                                    const Text('❌ Rejected by Manager',
                                        style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
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
                                      color: isRejected ? Colors.grey : theme.colorScheme.primary,
                                    ),
                                  ),
                                  if (isManager && (isPending || isPendingDelete)) ...[
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                                      tooltip: 'Approve',
                                      onPressed: () async {
                                        if (isPendingDelete) {
                                          await depositRepo.deleteDeposit(
                                            messId: messId,
                                            depositId: dep.id,
                                            memberId: dep.memberId,
                                            amount: dep.amount,
                                            status: dep.status,
                                          );
                                        } else {
                                          await depositRepo.updateDepositStatus(
                                            messId: messId,
                                            depositId: dep.id,
                                            memberId: dep.memberId,
                                            amount: dep.amount,
                                            newStatus: 'approved',
                                            previousStatus: dep.status,
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                                      tooltip: 'Reject',
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
                                  if (canModify && !isPendingDelete) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit_rounded, size: 20),
                                      tooltip: 'Edit Deposit',
                                      onPressed: () => _showAddOrEditDepositDialog(
                                        context,
                                        members: members,
                                        isManager: isManager,
                                        currentUserId: currentUserId,
                                        existingDeposit: dep,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                                      tooltip: 'Delete Deposit',
                                      onPressed: () => _handleDeleteDeposit(
                                        context,
                                        deposit: dep,
                                        isManager: isManager,
                                        currentUserId: currentUserId,
                                      ),
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
            onPressed: () => _showAddOrEditDepositDialog(
              context,
              members: members,
              isManager: isManager,
              currentUserId: currentUserId,
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(isManager ? 'Add Deposit' : 'Request Deposit'),
          ),
        );
      },
    );
  }
}
