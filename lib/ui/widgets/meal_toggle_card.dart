import 'package:flutter/material.dart';
import '../../core/enums.dart';
import '../../core/extensions.dart';
import '../../l10n/app_localizations.dart';

class MealToggleCard extends StatelessWidget {
  final String memberName;
  final double breakfast;
  final double lunch;
  final double dinner;
  final bool isLocked;
  final Function(String mealType, double currentVal) onToggle;

  const MealToggleCard({
    super.key,
    required this.memberName,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.isLocked,
    required this.onToggle,
  });

  Widget _buildToggleChip({
    required BuildContext context,
    required String label,
    required double value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final mealVal = MealValue.fromDouble(value);

    Color chipColor;
    Color textColor;
    String badgeText;

    switch (mealVal) {
      case MealValue.full:
        chipColor = theme.colorScheme.primary;
        textColor = Colors.white;
        badgeText = '1.0';
        break;
      case MealValue.half:
        chipColor = theme.colorScheme.secondary;
        textColor = Colors.white;
        badgeText = '0.5';
        break;
      case MealValue.none:
        chipColor = theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade200;
        textColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
        badgeText = '0.0';
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: isLocked ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLocked ? Colors.grey.shade400 : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                badgeText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = breakfast + lunch + dinner;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    memberName.isNotEmpty ? memberName[0].toUpperCase() : 'M',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    memberName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isLocked)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.lock_rounded, size: 18, color: Colors.orange),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total: ${total.toCleanString()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildToggleChip(
                  context: context,
                  label: l10n.breakfast,
                  value: breakfast,
                  onTap: () => onToggle('breakfast', breakfast),
                ),
                const SizedBox(width: 8),
                _buildToggleChip(
                  context: context,
                  label: l10n.lunch,
                  value: lunch,
                  onTap: () => onToggle('lunch', lunch),
                ),
                const SizedBox(width: 8),
                _buildToggleChip(
                  context: context,
                  label: l10n.dinner,
                  value: dinner,
                  onTap: () => onToggle('dinner', dinner),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
