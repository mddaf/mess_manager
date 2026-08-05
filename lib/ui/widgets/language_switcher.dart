import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/locale/locale_bloc.dart';
import '../../blocs/locale/locale_event.dart';
import '../../blocs/locale/locale_state.dart';

class LanguageSwitcherButton extends StatelessWidget {
  const LanguageSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        final isBangla = state.isBangla;
        return TextButton.icon(
          icon: const Icon(Icons.language_rounded, size: 20),
          label: Text(
            isBangla ? 'EN' : 'বাংলা',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            final nextLocale =
                isBangla ? const Locale('en') : const Locale('bn');
            context.read<LocaleBloc>().add(ChangeLocaleRequested(nextLocale));
          },
        );
      },
    );
  }
}
