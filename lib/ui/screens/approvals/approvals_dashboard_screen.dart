import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/extensions.dart';
import '../../../data/repositories/deposit_repository.dart';
import '../../../data/repositories/grocery_repository.dart';
import '../../../data/repositories/mess_repository.dart';
import '../../../models/deposit.dart';
import '../../../models/grocery_entry.dart';
import '../../../models/member.dart';

class ApprovalsDashboardScreen extends StatelessWidget {
  final String messId;

  const ApprovalsDashboardScreen({super.key, required this.messId});

  @override
  Widget build(BuildContext context) {
    final monthStr = DateFormat('yyyy-MM').format(DateTime.now());

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Approvals Dashboard'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Groceries'),
              Tab(icon: Icon(Icons.attach_money_rounded), text: 'Deposits'),
              Tab(icon: Icon(Icons.person_add_outlined), text: 'Member Joins'),
              Tab(icon: Icon(Icons.edit_attributes_outlined), text: 'Profile Edits'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PendingGroceriesTab(messId: messId, monthStr: monthStr),
            _PendingDepositsTab(messId: messId, monthStr: monthStr),
            _PendingMembersTab(messId: messId),
            _PendingProfileEditsTab(messId: messId),
          ],
        ),
      ),
    );
  }
}

class _PendingGroceriesTab extends StatelessWidget {
  final String messId;
  final String monthStr;

  const _PendingGroceriesTab({required this.messId, required this.monthStr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groceryRepo = context.read<GroceryRepository>();

    return StreamBuilder<List<GroceryEntry>>(
      stream: groceryRepo.watchMonthlyGroceries(
          messId: messId, monthPrefix: monthStr),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final pendingList = (snapshot.data ?? [])
            .where((g) => g.status == 'pending')
            .toList();

        if (pendingList.isEmpty) {
          return const Center(
            child: Text('🎉 No pending grocery entries to approve!'),
          );
        }

        return ListView.builder(
          itemCount: pendingList.length,
          itemBuilder: (context, index) {
            final item = pendingList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                title: Text(item.description,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    '${item.purchaserName} • ${item.date}\nAmount: ${item.amount.toCurrency()}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 28),
                      tooltip: 'Approve',
                      onPressed: () async {
                        await groceryRepo.updateGroceryStatus(
                          messId: messId,
                          entryId: item.id,
                          status: 'approved',
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded,
                          color: Colors.red, size: 28),
                      tooltip: 'Reject',
                      onPressed: () async {
                        await groceryRepo.updateGroceryStatus(
                          messId: messId,
                          entryId: item.id,
                          status: 'rejected',
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PendingDepositsTab extends StatelessWidget {
  final String messId;
  final String monthStr;

  const _PendingDepositsTab({required this.messId, required this.monthStr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final depositRepo = context.read<DepositRepository>();

    return StreamBuilder<List<Deposit>>(
      stream: depositRepo.watchMonthlyDeposits(
          messId: messId, monthPrefix: monthStr),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final pendingList = (snapshot.data ?? [])
            .where((d) => d.status == 'pending')
            .toList();

        if (pendingList.isEmpty) {
          return const Center(
            child: Text('🎉 No pending deposits to approve!'),
          );
        }

        return ListView.builder(
          itemCount: pendingList.length,
          itemBuilder: (context, index) {
            final dep = pendingList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                  child: const Icon(Icons.attach_money_rounded),
                ),
                title: Text(dep.memberName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Amount: ${dep.amount.toCurrency()}\nNote: ${dep.note} (${dep.date})'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 28),
                      tooltip: 'Approve',
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
                      icon: const Icon(Icons.cancel_rounded,
                          color: Colors.red, size: 28),
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
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PendingMembersTab extends StatelessWidget {
  final String messId;

  const _PendingMembersTab({required this.messId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messRepo = context.read<MessRepository>();

    return StreamBuilder<List<Member>>(
      stream: messRepo.watchMembers(messId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final pendingList = (snapshot.data ?? [])
            .where((m) => m.status == 'pending')
            .toList();

        if (pendingList.isEmpty) {
          return const Center(
            child: Text('🎉 No pending member joins!'),
          );
        }

        return ListView.builder(
          itemCount: pendingList.length,
          itemBuilder: (context, index) {
            final member = pendingList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: const Icon(Icons.person_add_rounded),
                ),
                title: Text(member.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(member.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 28),
                      tooltip: 'Approve Member',
                      onPressed: () async {
                        await messRepo.approveMemberJoin(
                            messId: messId, memberId: member.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded,
                          color: Colors.red, size: 28),
                      tooltip: 'Reject Member',
                      onPressed: () async {
                        await messRepo.rejectMemberJoin(
                            messId: messId, memberId: member.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PendingProfileEditsTab extends StatelessWidget {
  final String messId;

  const _PendingProfileEditsTab({required this.messId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messRepo = context.read<MessRepository>();

    return StreamBuilder<List<Member>>(
      stream: messRepo.watchMembers(messId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final pendingEdits = (snapshot.data ?? [])
            .where((m) => m.pendingName != null && m.pendingName!.isNotEmpty)
            .toList();

        if (pendingEdits.isEmpty) {
          return const Center(
            child: Text('🎉 No pending profile name changes!'),
          );
        }

        return ListView.builder(
          itemCount: pendingEdits.length,
          itemBuilder: (context, index) {
            final member = pendingEdits[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: const Icon(Icons.edit_rounded),
                ),
                title: Text('Current: ${member.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Requested Name: ${member.pendingName}',
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 28),
                      tooltip: 'Approve Name Change',
                      onPressed: () async {
                        await messRepo.approveMemberNameUpdate(
                          messId: messId,
                          memberId: member.id,
                          approvedName: member.pendingName!,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded,
                          color: Colors.red, size: 28),
                      tooltip: 'Reject Name Change',
                      onPressed: () async {
                        await messRepo.rejectMemberNameUpdate(
                          messId: messId,
                          memberId: member.id,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
