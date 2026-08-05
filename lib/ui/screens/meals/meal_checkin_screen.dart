import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/meal/meal_bloc.dart';
import '../../../blocs/meal/meal_event.dart';
import '../../../blocs/meal/meal_state.dart';
import '../../../blocs/mess/mess_bloc.dart';
import '../../../blocs/mess/mess_state.dart';
import '../../../models/meal_entry.dart';
import '../../../models/member.dart';
import '../../widgets/meal_toggle_card.dart';

class MealCheckinScreen extends StatelessWidget {
  final String messId;
  final String dateStr;

  const MealCheckinScreen({
    super.key,
    required this.messId,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final authState = context.watch<AuthBloc>().state;
    final currentUserId =
        authState is Authenticated ? authState.user.uid : '';

    final messState = context.watch<MessBloc>().state;
    List<Member> members = [];
    String managerId = '';
    if (messState is MessLoaded) {
      members = messState.members;
      managerId = messState.mess.currentManagerId ?? '';
    }

    final isManager = (currentUserId.isNotEmpty && currentUserId == managerId);

    return BlocBuilder<MealBloc, MealState>(
      builder: (context, state) {
        if (state is MealLoading && members.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        List<MealEntry> entries = [];
        double totalToday = 0.0;
        if (state is MealLoaded) {
          entries = state.entries;
          totalToday = state.totalMealsToday;
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📅 $dateStr',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isManager
                            ? 'Manager View • Can edit all meals'
                            : 'Member View • Can edit own meals only',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${l10n.totalMeals}: ${totalToday.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: members.isEmpty
                  ? Center(
                      child: Text(
                        'No members found in this mess.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final mId = member.userId;
                        final mName = member.name;

                        final matches = entries.where((e) => e.memberId == mId);
                        final entry = matches.isNotEmpty ? matches.first : null;

                        final b = entry?.breakfast ?? 0.0;
                        final l = entry?.lunch ?? 0.0;
                        final d = entry?.dinner ?? 0.0;
                        final isOwnMeal = (mId == currentUserId);
                        final canEdit = isManager || isOwnMeal;
                        final locked = (entry?.locked ?? false) || !canEdit;

                        return MealToggleCard(
                          memberName: isOwnMeal ? '$mName (You)' : mName,
                          breakfast: b,
                          lunch: l,
                          dinner: d,
                          isLocked: locked,
                          onToggle: (mealType, currentVal) {
                            if (canEdit) {
                              context.read<MealBloc>().add(
                                    ToggleMealRequested(
                                      messId: messId,
                                      memberId: mId,
                                      date: dateStr,
                                      mealType: mealType,
                                      currentVal: currentVal,
                                    ),
                                  );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Only the Manager can edit other members\' meals.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
