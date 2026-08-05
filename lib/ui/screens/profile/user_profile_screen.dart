import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/mess_repository.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  Future<void> _showEditProfileNameDialog(
      BuildContext context, String currentUserId, String currentName, List<String> messIds) async {
    final nameController = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();
    final messRepo = context.read<MessRepository>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Profile Name'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Request a name change. Member name edits require Admin approval.'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'New Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
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
              child: const Text('Submit Request'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final newName = nameController.text.trim();
      for (final mId in messIds) {
        await messRepo.requestMemberNameUpdate(
          messId: mId,
          memberId: currentUserId,
          newName: newName,
        );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Name change request submitted! Waiting for Admin approval.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _linkGoogleAccount(BuildContext context) async {
    final authRepo = context.read<AuthRepository>();
    try {
      await authRepo.linkGoogleAccount();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Account bound successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh Auth state
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Linking Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final authRepo = context.read<AuthRepository>();
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;

    String? validatePassword(String? val) {
      if (val == null || val.isEmpty) return 'Please enter a password';
      if (val.length < 8) return 'At least 8 characters required';
      if (!RegExp(r'[A-Z]').hasMatch(val)) return 'Need at least 1 uppercase letter';
      if (!RegExp(r'[a-z]').hasMatch(val)) return 'Need at least 1 lowercase letter';
      if (!RegExp(r'[0-9]').hasMatch(val)) return 'Need at least 1 number';
      if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(val)) {
        return 'Need at least 1 special character';
      }
      return null;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPassCtrl,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrent
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setDialogState(
                            () => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter current password' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPassCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setDialogState(() => obscureNew = !obscureNew),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPassCtrl,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setDialogState(
                            () => obscureConfirm = !obscureConfirm),
                      ),
                    ),
                    validator: (v) => v != newPassCtrl.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            StatefulBuilder(
              builder: (ctx2, setBtn) => ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setBtn(() => isSubmitting = true);
                        try {
                          await authRepo.changePassword(
                            currentPassword: currentPassCtrl.text,
                            newPassword: newPassCtrl.text,
                          );
                          Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password changed successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          final msg = e.code == 'wrong-password' ||
                                  e.code == 'invalid-credential'
                              ? 'Current password is incorrect.'
                              : e.message ?? e.code;
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(msg),
                                  backgroundColor: Colors.red),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red),
                            );
                          }
                        } finally {
                          setBtn(() => isSubmitting = false);
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Change Password'),
              ),
            ),
          ],
        ),
      ),
    );

    currentPassCtrl.dispose();
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;
          final authRepo = context.read<AuthRepository>();
          final isVerified = authRepo.isEmailVerified;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Email verification banner
                  if (!isVerified) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade400),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_unread_rounded, color: Colors.orange.shade800),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '⚠️ Your email is not verified yet. Please check your inbox (and spam folder).',
                              style: TextStyle(color: Colors.orange.shade900),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await authRepo.resendVerificationEmail();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Verification email resent! Check your inbox & spam folder.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            child: const Text('Resend'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Request Name Edit',
                        onPressed: () => _showEditProfileNameDialog(
                            context, user.uid, user.name, user.messIds),
                      ),
                    ],
                  ),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  // Profile details card
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline_rounded),
                          title: const Text('Full Name'),
                          subtitle: Text(user.name),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.email_outlined),
                          title: const Text('Email'),
                          subtitle: Text(user.email),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.g_mobiledata_rounded, size: 28),
                          title: const Text('Google Account'),
                          subtitle: Builder(builder: (ctx) {
                            final providerData = FirebaseAuth
                                    .instance.currentUser?.providerData ?? [];
                            final isLinked = providerData
                                .any((p) => p.providerId == 'google.com');
                            return Text(isLinked
                                ? '✅ Linked to Google Account'
                                : 'Not linked');
                          }),
                          trailing: OutlinedButton(
                            onPressed: () => _linkGoogleAccount(context),
                            child: Builder(builder: (ctx) {
                              final providerData = FirebaseAuth
                                      .instance.currentUser?.providerData ?? [];
                              final isLinked = providerData
                                  .any((p) => p.providerId == 'google.com');
                              return Text(isLinked ? 'Change' : 'Link Google');
                            }),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.lock_reset_rounded),
                          title: const Text('Change Password'),
                          subtitle: const Text('Update your account password'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _showChangePasswordDialog(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.home_work_outlined),
                          title: const Text('Messes Joined'),
                          subtitle: Text('${user.messIds.length} mess(es)'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.calendar_today_outlined),
                          title: const Text('Member Since'),
                          subtitle: Text(
                            user.createdAt != null
                                ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                                : 'Unknown',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Sign out button
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignOutRequested());
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      side: BorderSide(color: theme.colorScheme.error),
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
