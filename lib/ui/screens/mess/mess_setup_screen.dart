import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/mess/mess_bloc.dart';
import '../../../blocs/mess/mess_event.dart';
import '../../../blocs/mess/mess_state.dart';
import '../../../data/repositories/mess_repository.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/theme_toggle.dart';

class MessSetupScreen extends StatefulWidget {
  const MessSetupScreen({super.key});

  @override
  State<MessSetupScreen> createState() => _MessSetupScreenState();
}

class _MessSetupScreenState extends State<MessSetupScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _createFormKey = GlobalKey<FormState>();
  final _joinFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Auto-load mess for returning users who already belong to one
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthBloc>().state;
      if (auth is Authenticated && auth.user.messIds.isNotEmpty) {
        context
            .read<MessBloc>()
            .add(WatchMessRequested(auth.user.messIds.first));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  AuthState get _authState => context.read<AuthBloc>().state;

  Future<void> _createMess() async {
    if (!_createFormKey.currentState!.validate()) return;
    final auth = _authState;
    if (auth is! Authenticated) return;
    setState(() => _loading = true);
    try {
      final repo = context.read<MessRepository>();
      final mess = await repo.createMess(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        userId: auth.user.uid,
        userName: auth.user.name,
        userEmail: auth.user.email,
      );
      if (mounted) {
        context.read<MessBloc>().add(WatchMessRequested(mess.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _joinMess() async {
    if (!_joinFormKey.currentState!.validate()) return;
    final auth = _authState;
    if (auth is! Authenticated) return;
    setState(() => _loading = true);
    try {
      final repo = context.read<MessRepository>();
      final mess = await repo.joinMessWithInviteCode(
        inviteCode: _inviteCodeController.text.trim().toUpperCase(),
        userId: auth.user.uid,
        userName: auth.user.name,
        userEmail: auth.user.email,
      );
      if (mess != null && mounted) {
        context.read<MessBloc>().add(WatchMessRequested(mess.id));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid invite code. Please check and try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<MessBloc, MessState>(
      listener: (context, state) {
        if (state is MessLoaded) {
          context.go('/home?messId=${state.mess.id}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          actions: const [LanguageSwitcherButton(), ThemeToggleIconButton()],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.add_home_rounded), text: 'Create Mess'),
              Tab(icon: Icon(Icons.group_add_rounded), text: 'Join Mess'),
            ],
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SizedBox(
                height: 440,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                  // ── CREATE MESS TAB ──────────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _createFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(Icons.home_work_rounded,
                                size: 48, color: theme.colorScheme.primary),
                            const SizedBox(height: 8),
                            Text('Create a New Mess',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Mess Name',
                                prefixIcon: Icon(Icons.restaurant_rounded),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter mess name'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address / Location',
                                prefixIcon: Icon(Icons.location_on_rounded),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter address'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _loading ? null : _createMess,
                              icon: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Icon(Icons.add_rounded),
                              label: const Text('Create Mess'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ── JOIN MESS TAB ─────────────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _joinFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(Icons.group_add_rounded,
                                size: 48, color: theme.colorScheme.secondary),
                            const SizedBox(height: 8),
                            Text('Join Existing Mess',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                                'Enter the 6-character invite code shared by your flatmate.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme
                                        .colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _inviteCodeController,
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 6,
                              decoration: const InputDecoration(
                                labelText: 'Invite Code (e.g. MESS88)',
                                prefixIcon: Icon(Icons.vpn_key_rounded),
                                counterText: '',
                              ),
                              style: const TextStyle(
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter invite code';
                                }
                                if (v.trim().length != 6) {
                                  return 'Code must be 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _loading ? null : _joinMess,
                              icon: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Icon(Icons.login_rounded),
                              label: const Text('Join Mess'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
