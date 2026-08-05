import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/mess/mess_bloc.dart';
import '../../../blocs/mess/mess_state.dart';
import '../../../data/repositories/mess_repository.dart';
import '../../../models/member.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/theme_toggle.dart';

class MessProfileScreen extends StatelessWidget {
  final String messId;

  const MessProfileScreen({super.key, required this.messId});

  Future<void> _rotateManager(BuildContext context, List<Member> members) async {
    final current = context.read<MessBloc>().state;
    if (current is! MessLoaded) return;
    final currentManagerId = current.mess.currentManagerId;
    // Cache repo before async gap
    final repo = context.read<MessRepository>();

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign New Manager'),
        content: SizedBox(
          width: 320,
          child: ListView(
            shrinkWrap: true,
            children: members.map((m) {
              final isCurrentManager = m.userId == currentManagerId;
              return ListTile(
                leading: CircleAvatar(
                  child: Text(m.name[0].toUpperCase()),
                ),
                title: Text(m.name),
                subtitle: Text(m.email),
                trailing: isCurrentManager
                    ? Chip(
                        label: const Text('Current'),
                        backgroundColor:
                            Theme.of(ctx).colorScheme.primaryContainer,
                      )
                    : null,
                onTap: isCurrentManager
                    ? null
                    : () => Navigator.of(ctx).pop(m.userId),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null) {
      final name = members.firstWhere((m) => m.userId == selected).name;
      try {
        await repo.rotateManager(messId: messId, newManagerId: selected);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name is now the manager!')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteMess(BuildContext context, String userId) async {
    // Cache repo and router before async gap
    final repo = context.read<MessRepository>();
    final router = GoRouter.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_rounded,
            color: Theme.of(ctx).colorScheme.error, size: 40),
        title: const Text('Delete Mess'),
        content: const Text(
          'This will permanently delete the mess and all its data '
          '(meals, groceries, settlements). This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await repo.deleteMess(messId: messId, userId: userId);
        if (!context.mounted) return;
        router.go('/setup');
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removeMember(
      BuildContext context, Member member, String adminId) async {
    if (member.userId == adminId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't remove yourself from the mess.")),
      );
      return;
    }
    // Cache repo before async gap
    final repo = context.read<MessRepository>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${member.name}?'),
        content: Text(
            '${member.name} will be removed from this mess. They can rejoin with the invite code.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await repo.removeMember(messId: messId, memberId: member.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final currentUserId =
        authState is Authenticated ? authState.user.uid : '';

    return BlocBuilder<MessBloc, MessState>(
      builder: (context, state) {
        if (state is MessLoading || state is MessInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MessError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is! MessLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final mess = state.mess;
        final members = state.members;
        final isAdmin = members
            .any((m) => m.userId == currentUserId && m.role == 'admin');
        final isManager = mess.currentManagerId == currentUserId;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Mess Header ─────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(Icons.home_work_rounded,
                                size: 28, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(mess.name,
                                    style: theme.textTheme.titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(mess.address,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      // Invite code row
                      Row(
                        children: [
                          Icon(Icons.vpn_key_rounded,
                              color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Invite Code:',
                              style: theme.textTheme.labelLarge),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              mess.inviteCode,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                fontSize: 16,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            tooltip: 'Copy Code',
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: mess.inviteCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Invite code copied!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Current Manager ──────────────────────────────────
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.manage_accounts_rounded),
                      title: Text(l10n.currentManager),
                      subtitle: Text(
                        members
                                .where(
                                    (m) => m.userId == mess.currentManagerId)
                                .firstOrNull
                                ?.name ??
                            'Not assigned',
                      ),
                      trailing: (isAdmin || isManager)
                          ? TextButton.icon(
                              icon: const Icon(Icons.swap_horiz_rounded),
                              label: const Text('Rotate'),
                              onPressed: () =>
                                  _rotateManager(context, members),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── App Settings ─────────────────────────────────────
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language_rounded),
                      title: Text(l10n.language),
                      trailing: const LanguageSwitcherButton(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.dark_mode_rounded),
                      title: Text(l10n.darkMode),
                      trailing: const ThemeToggleIconButton(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Members List ─────────────────────────────────────
              Row(
                children: [
                  Text('Members (${members.length})',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ...members.map((member) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Text(
                          member.name.isNotEmpty
                              ? member.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(member.name),
                      subtitle: Text(member.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(
                              member.role == 'admin'
                                  ? 'Admin'
                                  : member.userId == mess.currentManagerId
                                      ? 'Manager'
                                      : 'Member',
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: member.role == 'admin'
                                ? theme.colorScheme.errorContainer
                                : member.userId == mess.currentManagerId
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surfaceContainerHighest,
                          ),
                          if (isAdmin && member.userId != currentUserId)
                            IconButton(
                              icon: const Icon(Icons.person_remove_rounded,
                                  size: 20),
                              tooltip: 'Remove Member',
                              color: theme.colorScheme.error,
                              onPressed: () =>
                                  _removeMember(context, member, currentUserId),
                            ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 24),

              // ── Danger Zone ──────────────────────────────────────
              if (isAdmin) ...[
                Text('Danger Zone',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error)),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.delete_forever_rounded,
                        color: theme.colorScheme.error),
                    title: Text('Delete This Mess',
                        style:
                            TextStyle(color: theme.colorScheme.error)),
                    subtitle: const Text(
                        'Permanently remove mess and all data.'),
                    trailing: ElevatedButton(
                      onPressed: () => _deleteMess(context, currentUserId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }
}
