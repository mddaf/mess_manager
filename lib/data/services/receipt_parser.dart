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
  /// Robustly extracts total amount from recognized OCR text
  static double? parseTotalAmount(String text) {
    if (text.trim().isEmpty) return null;

    // Convert any Bangla numerals to English numerals first
    final normalizedText = text.toEnglishNumerals();
    final lines = normalizedText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return null;

    // High-priority total keywords
    final highPriorityKeywords = [
      'grand total',
      'net total',
      'net amount',
      'total amount',
      'bill amount',
      'payable',
      'paid amount',
      'সর্বমোট',
      'মোট টাকা',
    ];

    // Medium-priority total keywords
    final mediumPriorityKeywords = [
      'total',
      'amount',
      'subtotal',
      'sub total',
      'cash',
      'মোট',
      'টাকা',
      'tk',
      'bdt',
    ];

    final numberRegex = RegExp(
        r'(?:৳|\$|Tk|TK|Tk\.|TK\.|BDT)?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)',
        caseSensitive: false);

    bool isDateLine(String line) {
      final lower = line.toLowerCase();
      if (lower.contains('date')) return true;
      return RegExp(r'\d{4}[-/]\d{1,2}[-/]\d{1,2}').hasMatch(line) ||
          RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}').hasMatch(line);
    }

    // 1. Check for High-Priority Keyword on same line or adjacent lines
    for (int i = 0; i < lines.length; i++) {
      final lineLower = lines[i].toLowerCase();
      if (highPriorityKeywords.any((kw) => lineLower.contains(kw))) {
        final amt = _extractNumberFromLine(lines[i], numberRegex);
        if (amt != null) return amt;

        // Check next line if number was on separate line
        if (i + 1 < lines.length && !isDateLine(lines[i + 1])) {
          final nextAmt = _extractNumberFromLine(lines[i + 1], numberRegex);
          if (nextAmt != null) return nextAmt;
        }
      }
    }

    // 2. Check for Medium-Priority Keyword on same line or adjacent lines
    for (int i = 0; i < lines.length; i++) {
      final lineLower = lines[i].toLowerCase();
      if (mediumPriorityKeywords.any((kw) => lineLower.contains(kw))) {
        final amt = _extractNumberFromLine(lines[i], numberRegex);
        if (amt != null) return amt;

        if (i + 1 < lines.length && !isDateLine(lines[i + 1])) {
          final nextAmt = _extractNumberFromLine(lines[i + 1], numberRegex);
          if (nextAmt != null) return nextAmt;
        }
      }
    }

    // 3. Fallback: Find maximum plausible non-date, non-phone number in the text
    double? maxPlausibleAmount;

    for (final line in lines) {
      // Skip date-like lines (e.g. 2026-08-05, 05/08/2026) and phone numbers (017..., 018...)
      if (isDateLine(line) ||
          RegExp(r'^01[3-9]\d{8}$').hasMatch(line.replaceAll(RegExp(r'\s+'), ''))) {
        continue;
      }

      final matches = numberRegex.allMatches(line);
      for (final match in matches) {
        final numStr = match.group(1)?.replaceAll(',', '');
        if (numStr != null) {
          final val = double.tryParse(numStr);
          if (val != null && val > 0 && val < 500000) {
            // Avoid year numbers like 2020..2030 if standalone integer
            if (val >= 2020 && val <= 2030 && !line.contains('.')) continue;

            if (maxPlausibleAmount == null || val > maxPlausibleAmount) {
              maxPlausibleAmount = val;
            }
          }
        }
      }
    }

    return maxPlausibleAmount;
  }

  static double? _extractNumberFromLine(String line, RegExp numberRegex) {
    final matches = numberRegex.allMatches(line);
    double? bestVal;
    for (final match in matches) {
      final numStr = match.group(1)?.replaceAll(',', '');
      if (numStr != null) {
        final val = double.tryParse(numStr);
        if (val != null && val > 0 && val < 500000) {
          if (val >= 2020 && val <= 2030 && !line.contains('.')) continue;
          bestVal = val;
        }
      }
    }
    return bestVal;
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
