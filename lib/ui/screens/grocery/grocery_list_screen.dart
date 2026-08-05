import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../../blocs/grocery/grocery_bloc.dart';
import '../../../blocs/grocery/grocery_state.dart';
import '../../../core/extensions.dart';
import '../../../models/grocery_entry.dart';
import '../../widgets/grocery_item_tile.dart';
import 'add_grocery_screen.dart';

class GroceryListScreen extends StatelessWidget {
  final String messId;
  final String monthStr;

  const GroceryListScreen({
    super.key,
    required this.messId,
    required this.monthStr,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<GroceryBloc, GroceryState>(
      builder: (context, state) {
        if (state is GroceryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<GroceryEntry> entries = [];
        double total = 0.0;
        if (state is GroceryLoaded) {
          entries = state.entries;
          total = state.totalGroceryCost;
        }

        return Scaffold(
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: theme.colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalGrocery,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      total.toCurrency(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Text(
                          'No grocery entries logged yet.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final item = entries[index];
                          return GroceryItemTile(
                            description: item.description,
                            amount: item.amount,
                            purchaserName: item.purchaserName,
                            date: item.date,
                            receiptUrl: item.receiptUrl,
                            ocrExtractedAmount: item.ocrExtractedAmount,
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddGroceryScreen(messId: messId),
                ),
              );
            },
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: Text(l10n.addGrocery),
          ),
        );
      },
    );
  }
}
