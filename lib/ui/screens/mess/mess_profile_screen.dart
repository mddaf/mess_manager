import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/mess/mess_bloc.dart';
import '../../../blocs/mess/mess_state.dart';
import '../../../data/repositories/mess_repository.dart';
import '../../../models/member.dart';
import '../../../models/mess.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/theme_toggle.dart';
import '../approvals/approvals_dashboard_screen.dart';

import '../../../data/services/api_service.dart';

class MessProfileScreen extends StatelessWidget {
  final String messId;

  const MessProfileScreen({super.key, required this.messId});

  Future<void> _showEditMessDialog(BuildContext context, Mess mess) async {
    final nameController = TextEditingController(text: mess.name);
    final addressController = TextEditingController(text: mess.address);
    int cutoffHour = mess.mealCutoffHour;
    final formKey = GlobalKey<FormState>();
    final repo = context.read<MessRepository>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Mess Details'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Mess Name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter mess name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter address' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: cutoffHour,
                        decoration: const InputDecoration(labelText: 'Daily Meal Cutoff Time'),
                        items: const [
                          DropdownMenuItem(value: 20, child: Text('8:00 PM')),
                          DropdownMenuItem(value: 21, child: Text('9:00 PM')),
                          DropdownMenuItem(value: 22, child: Text('10:00 PM (Default)')),
                          DropdownMenuItem(value: 23, child: Text('11:00 PM')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => cutoffHour = val);
                        },
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
                    if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      await repo.updateMessDetails(
        messId: messId,
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        mealCutoffHour: cutoffHour,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mess details updated!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _showSendEmailInviteDialog(
      BuildContext context, String currentUserId, String currentRole) async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final repo = context.read<MessRepository>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Send Email Invite Link'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter recipient email to bind invite code to that specific email:'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Target Member Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter email';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter valid email';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
              },
              child: const Text('Generate Invite Link'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      if (!context.mounted) return;
      final targetEmail = emailController.text.trim().toLowerCase();
      final messState = context.read<MessBloc>().state;
      final messName = messState is MessLoaded ? messState.mess.name : 'Mess';
      final authState = context.read<AuthBloc>().state;
      final senderName = authState is Authenticated ? authState.user.name : 'Flatmate';

      final code = await repo.createEmailInvite(
        messId: messId,
        targetEmail: targetEmail,
        invitedByUserId: currentUserId,
        invitedByRole: currentRole,
      );

      final link = 'https://meal-manager-844f5.web.app/join?code=$code&email=$targetEmail';

      // 1. Copy to clipboard
      Clipboard.setData(ClipboardData(text: link));

      // 2. Trigger Cloud Function API email delivery attempt
      ApiService().sendInviteEmail(
        targetEmail: targetEmail,
        messName: messName,
        inviteCode: code,
        inviteLink: link,
        senderName: senderName,
      );

      final subjectRaw = 'You are invited to join $messName on Mess Manager';
      final bodyRaw =
          'Hi,\n\n$senderName invited you to join $messName on Mess Manager.\n\n'
          'Invite Code: $code\n'
          'Direct Link: $link\n\n'
          'This invite is bound to $targetEmail.';

      final subjectEncoded = Uri.encodeComponent(subjectRaw);
      final bodyEncoded = Uri.encodeComponent(bodyRaw);

      final gmailWebUri = Uri.parse(
          'https://mail.google.com/mail/?view=cm&fs=1&to=$targetEmail&su=$subjectEncoded&body=$bodyEncoded');
      final mailtoUri = Uri.parse('mailto:$targetEmail?subject=$subjectEncoded&body=$bodyEncoded');
      final waUri = Uri.parse('https://wa.me/?text=$bodyEncoded');

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('🎉 Invite Link Created!'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.vpn_key_rounded, color: Colors.orange.shade800, size: 20),
                            const SizedBox(width: 8),
                            Text('Invite Code: $code',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.orange.shade900)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Bound to: $targetEmail',
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade900)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Send options:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => launchUrl(gmailWebUri, mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.mark_email_read_rounded, size: 18),
                      label: const Text('Open in Gmail Web (Direct Compose)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(waUri, mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                      label: const Text('Share via WhatsApp'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(mailtoUri, mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.email_outlined, size: 18),
                      label: const Text('Open Default Mail App'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Direct Link (copied to clipboard):',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  SelectableText(link, style: const TextStyle(fontSize: 11, color: Colors.blue)),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _rotateManager(BuildContext context, List<Member> members) async {
    final current = context.read<MessBloc>().state;
    if (current is! MessLoaded) return;
    final currentManagerId = current.mess.currentManagerId;
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
    final repo = context.read<MessRepository>();
    final authBloc = context.read<AuthBloc>();
    final router = GoRouter.of(context);

    // Guard: Check if any member has unpaid dues
    final hasDues = await repo.hasAnyMemberDuesInMess(messId);
    if (hasDues) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Cannot delete mess: Member(s) have unpaid carried-forward dues. All member dues must be settled first.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_rounded,
            color: Theme.of(ctx).colorScheme.error, size: 40),
        title: const Text('Delete Mess'),
        content: const Text(
          'This will permanently delete the mess and all its data '
          '(meals, groceries, deposits, settlements). This action cannot be undone.',
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
        // Reload auth profile (clears messIds) before navigating to prevent back-loop
        authBloc.add(AuthCheckRequested());
        await Future.delayed(const Duration(milliseconds: 400));
        if (context.mounted) router.go('/setup');
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _leaveMess(
      BuildContext context,
      String currentUserId,
      String currentRole,
      Mess mess,
      List<Member> members) async {
    final approvedMembers =
        members.where((m) => m.status == 'approved').toList();

    // Guard: Check if current leaving member has unpaid carried dues
    final leavingMember = members.firstWhere((m) => m.userId == currentUserId,
        orElse: () => Member(id: currentUserId, userId: currentUserId, name: '', email: ''));
    if (leavingMember.openingDues > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ You cannot leave the mess because you have unpaid carried-forward dues of ৳${leavingMember.openingDues.toStringAsFixed(2)}. Please settle with the manager first.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    // Guard 1: Only admin in the mess must promote another admin first
    final isOnlyAdmin = currentRole == 'admin' &&
        approvedMembers.where((m) => m.role == 'admin').length == 1;

    // Guard 2: Must rotate manager first if they are current manager
    final isManager = mess.currentManagerId == currentUserId;

    final otherMembers =
        approvedMembers.where((m) => m.userId != currentUserId).toList();

    if (otherMembers.isEmpty) {
      // Last member — just delete the mess
      await _deleteAsLastMember(context, currentUserId);
      return;
    }

    if (isOnlyAdmin && isManager) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '⚠️ You must promote another Admin AND assign a new Manager before leaving.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (isOnlyAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '⚠️ You are the only Admin. Promote another member to Admin before leaving.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (isManager) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '⚠️ You are the current Manager. Assign a new Manager before leaving.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // All guards passed — confirm and leave
    final repo = context.read<MessRepository>();
    final authBloc = context.read<AuthBloc>();
    final router = GoRouter.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.exit_to_app_rounded, size: 40, color: Colors.orange),
        title: const Text('Leave Mess'),
        content: const Text(
            'Are you sure you want to leave this mess? You can rejoin with an invite code.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Leave Mess'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await repo.leaveMess(messId: messId, userId: currentUserId);
        if (!context.mounted) return;
        authBloc.add(AuthCheckRequested());
        await Future.delayed(const Duration(milliseconds: 400));
        if (context.mounted) router.go('/setup');
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteAsLastMember(
      BuildContext context, String currentUserId) async {
    final repo = context.read<MessRepository>();
    final authBloc = context.read<AuthBloc>();
    final router = GoRouter.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Mess'),
        content: const Text(
            'You are the last member. Leaving will permanently delete this mess and all its data.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete & Leave'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await repo.deleteMess(messId: messId, userId: currentUserId);
        if (!context.mounted) return;
        authBloc.add(AuthCheckRequested());
        await Future.delayed(const Duration(milliseconds: 400));
        if (context.mounted) router.go('/setup');
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
        final currentMember = members.firstWhere(
          (m) => m.userId == currentUserId,
          orElse: () => Member(id: '', userId: '', name: '', email: ''),
        );

        final isAdmin = currentMember.role == 'admin';
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
                          if (isAdmin)
                            IconButton(
                              icon: const Icon(Icons.edit_rounded),
                              tooltip: 'Edit Mess Details',
                              onPressed: () => _showEditMessDialog(context, mess),
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
                                    content: Text('Invite code copied!')),
                              );
                            },
                          ),
                          const Spacer(),
                          TextButton.icon(
                            icon: const Icon(Icons.forward_to_inbox_rounded, size: 18),
                            label: const Text('Email Invite Link'),
                            onPressed: () => _showSendEmailInviteDialog(
                                context, currentUserId, currentMember.role),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Admin & Manager Dashboard Action Card ─────────────
              if (isAdmin || isManager) ...[
                Card(
                  color: theme.colorScheme.tertiaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.dashboard_customize_rounded),
                    title: const Text('Approvals Dashboard',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text(
                        'Review pending groceries, deposits, member joins & profile edits'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ApprovalsDashboardScreen(messId: messId),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

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
              ...members.map((member) {
                final isPendingJoin = (member.status == 'pending');

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPendingJoin
                          ? theme.colorScheme.tertiaryContainer
                          : theme.colorScheme.secondaryContainer,
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.email),
                        if (isPendingJoin)
                          const Text(
                            '⏳ Pending Admin Approval',
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
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
                );
              }),
              const SizedBox(height: 24),

              // ── Leave + Danger Zone ─────────────────────────────────
              Text('Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Leave Mess — visible to all members
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orange.shade300),
                ),
                child: ListTile(
                  leading: const Icon(Icons.exit_to_app_rounded,
                      color: Colors.orange),
                  title: const Text('Leave Mess',
                      style: TextStyle(color: Colors.orange)),
                  subtitle: const Text(
                      'Admin/Manager must reassign roles before leaving.'),
                  trailing: OutlinedButton(
                    onPressed: () => _leaveMess(
                        context, currentUserId, currentMember.role, mess, members),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange)),
                    child: const Text('Leave'),
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
