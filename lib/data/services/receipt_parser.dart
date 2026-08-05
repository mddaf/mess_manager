import '../../core/extensions.dart';

class OcrResult {
  final String rawText;
  final double? extractedTotal;
  final List<String> extractedItems;
  final double confidence;

  OcrResult({
    required this.rawText,
    this.extractedTotal,
    this.extractedItems = const [],
    this.confidence = 0.0,
  });
}

class ReceiptParser {
  /// Extracts total amount from recognized OCR text
  static double? parseTotalAmount(String text) {
    if (text.isEmpty) return null;

    // Convert any Bangla numerals to English numerals first
    final normalizedText = text.toEnglishNumerals();
    final lines = normalizedText.split('\n');

    // Keywords to search for total
    final totalKeywords = [
      'total',
      'grand total',
      'net total',
      'amount',
      'মোট',
      'সর্বমোট',
      'টাকা',
      'subtotal',
      'cash'
    ];

    double? maxAmount;

    for (final line in lines) {
      final lower = line.toLowerCase();
      final hasKeyword = totalKeywords.any((kw) => lower.contains(kw));

      // Regex matching amounts like 1,250.00 or 1250 or 450.50
      final matches = RegExp(r'(?:৳|\$|Tk|TK|BDT)?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)')
          .allMatches(line);

      for (final match in matches) {
        final numStr = match.group(1)?.replaceAll(',', '');
        if (numStr != null) {
          final val = double.tryParse(numStr);
          if (val != null && val > 0 && val < 500000) { // Reasonable upper bound
            if (hasKeyword) {
              return val; // High priority match next to a total keyword
            }
            if (maxAmount == null || val > maxAmount) {
              maxAmount = val;
            }
          }
        }
      }
    }

    return maxAmount;
  }

  /// Extracts item names/lines
  static List<String> parseItems(String text) {
    final lines = text.split('\n');
    return lines
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && l.length > 3)
        .take(10)
        .toList();
  }
}
