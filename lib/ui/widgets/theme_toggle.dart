import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_event.dart';
import '../../blocs/theme/theme_state.dart';

class ThemeToggleIconButton extends StatelessWidget {
  const ThemeToggleIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state.isDarkMode;
        return IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          onPressed: () {
            context.read<ThemeBloc>().add(ToggleThemeRequested());
          },
        );
      },
    );
  }
}
