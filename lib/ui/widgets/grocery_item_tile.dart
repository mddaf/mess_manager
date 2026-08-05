import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/extensions.dart';

class GroceryItemTile extends StatelessWidget {
  final String description;
  final double amount;
  final String purchaserName;
  final String date;
  final String? receiptUrl;
  final double? ocrExtractedAmount;
  final VoidCallback? onDelete;

  const GroceryItemTile({
    super.key,
    required this.description,
    required this.amount,
    required this.purchaserName,
    required this.date,
    this.receiptUrl,
    this.ocrExtractedAmount,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: receiptUrl != null && receiptUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: receiptUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey.shade300),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.receipt_long_rounded),
                ),
              )
            : CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$purchaserName • $date',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount.toCurrency(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (ocrExtractedAmount != null)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'OCR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
