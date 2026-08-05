import '../../core/extensions.dart';

class ParsedItem {
  final String name;
  final double price;

  ParsedItem({required this.name, required this.price});
}

class OcrResult {
  final String rawText;
  final double? extractedTotal;
  final List<double> candidateAmounts;
  final List<ParsedItem> parsedItems;
  final List<String> extractedItems;
  final double confidence;

  OcrResult({
    required this.rawText,
    this.extractedTotal,
    this.candidateAmounts = const [],
    this.parsedItems = const [],
    this.extractedItems = const [],
    this.confidence = 0.0,
  });
}

class ReceiptParser {
  /// Robustly extracts total amount, candidate amounts, and itemized lines from recognized OCR text
  static OcrResult parse(String text) {
    if (text.trim().isEmpty) {
      return OcrResult(rawText: text);
    }

    // 1. Convert Bangla numerals to English numerals & normalize handwritten text
    final normalizedText = _normalizeHandwrittenText(text);
    final lines = normalizedText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return OcrResult(rawText: text);
    }

    final candidateAmounts = <double>[];
    final parsedItems = <ParsedItem>[];

    // Number extraction regex supporting currency symbols, handwritten suffix (/- or /=)
    final numberRegex = RegExp(
      r'(?:৳|\$|Tk|TK|Tk\.|TK\.|BDT|Rs|Rs\.)?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)(?:\s*(?:/-|/=|tk|taka|টাকা|৳))?',
      caseSensitive: false,
    );

    // High-priority total keywords (Printed & Handwritten Bengali / English)
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
      'মোট বিল',
      'মোট-',
      'মোট=',
    ];

    // Medium-priority keywords
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
      'বিল',
    ];

    double? extractedTotal;
    double confidence = 0.5;

    // Helper to check if a line is date or phone number
    bool isDateOrPhoneLine(String line) {
      final lower = line.toLowerCase();
      if (lower.contains('date') || lower.contains('phone') || lower.contains('mobile') || lower.contains('tel')) {
        return true;
      }
      final cleanDigits = line.replaceAll(RegExp(r'\D'), '');
      if (cleanDigits.length >= 10 && (cleanDigits.startsWith('01') || cleanDigits.startsWith('8801'))) {
        return true;
      }
      return RegExp(r'\d{4}[-/]\d{1,2}[-/]\d{1,2}').hasMatch(line) ||
          RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}').hasMatch(line);
    }

    // A. Check for summation line (e.g. "120 + 180 = 300" or "= 300/-")
    for (final line in lines) {
      final sumMatch = RegExp(r'=\s*(\d+(?:\.\d{1,2})?)', caseSensitive: false).firstMatch(line);
      if (sumMatch != null) {
        final val = double.tryParse(sumMatch.group(1)!);
        if (val != null && val > 0 && val < 500000) {
          extractedTotal = val;
          confidence = 0.95;
          break;
        }
      }
    }

    // B. Check for High-Priority Keyword on same or next line
    if (extractedTotal == null) {
      for (int i = 0; i < lines.length; i++) {
        final lineLower = lines[i].toLowerCase();
        if (highPriorityKeywords.any((kw) => lineLower.contains(kw))) {
          final amt = _extractNumberFromLine(lines[i], numberRegex);
          if (amt != null) {
            extractedTotal = amt;
            confidence = 0.9;
            break;
          }
          if (i + 1 < lines.length && !isDateOrPhoneLine(lines[i + 1])) {
            final nextAmt = _extractNumberFromLine(lines[i + 1], numberRegex);
            if (nextAmt != null) {
              extractedTotal = nextAmt;
              confidence = 0.85;
              break;
            }
          }
        }
      }
    }

    // C. Check for Medium-Priority Keyword
    if (extractedTotal == null) {
      for (int i = 0; i < lines.length; i++) {
        final lineLower = lines[i].toLowerCase();
        if (mediumPriorityKeywords.any((kw) => lineLower.contains(kw))) {
          final amt = _extractNumberFromLine(lines[i], numberRegex);
          if (amt != null) {
            extractedTotal = amt;
            confidence = 0.75;
            break;
          }
          if (i + 1 < lines.length && !isDateOrPhoneLine(lines[i + 1])) {
            final nextAmt = _extractNumberFromLine(lines[i + 1], numberRegex);
            if (nextAmt != null) {
              extractedTotal = nextAmt;
              confidence = 0.70;
              break;
            }
          }
        }
      }
    }

    // D. Extract Itemized Lines (e.g. "Rice 150", "তেল ২০০/-") & Candidate Amounts
    for (final line in lines) {
      if (isDateOrPhoneLine(line)) continue;

      final matches = numberRegex.allMatches(line);
      for (final match in matches) {
        final numStr = match.group(1)?.replaceAll(',', '');
        if (numStr != null) {
          final val = double.tryParse(numStr);
          if (val != null && val > 0 && val < 500000) {
            // Filter out calendar years (2020..2030) if standalone
            if (val >= 2020 && val <= 2030 && !line.contains('.')) continue;

            if (!candidateAmounts.contains(val)) {
              candidateAmounts.add(val);
            }

            // Extract item name by removing the number and symbols
            final itemName = line.replaceAll(match.group(0)!, '').replaceAll(RegExp(r'[:-=/]+'), '').trim();
            if (itemName.length >= 2) {
              parsedItems.add(ParsedItem(name: itemName, price: val));
            }
          }
        }
      }
    }

    // E. Fallback: Maximum plausible amount
    if (extractedTotal == null && candidateAmounts.isNotEmpty) {
      // Sort candidate amounts descending
      candidateAmounts.sort((a, b) => b.compareTo(a));
      extractedTotal = candidateAmounts.first;
      confidence = 0.60;
    } else {
      candidateAmounts.sort((a, b) => b.compareTo(a));
    }

    final extractedItemNames = parsedItems.map((p) => '${p.name}: ৳${p.price.toStringAsFixed(0)}').toList();

    return OcrResult(
      rawText: text,
      extractedTotal: extractedTotal,
      candidateAmounts: candidateAmounts,
      parsedItems: parsedItems,
      extractedItems: extractedItemNames.isNotEmpty ? extractedItemNames : parseItems(text),
      confidence: confidence,
    );
  }

  /// Normalizes handwritten OCR text, converting Bangla digits and handwritten OCR noise
  static String _normalizeHandwrittenText(String text) {
    var s = text.toEnglishNumerals();

    // Fix common handwritten OCR digit confusions in numeric patterns (e.g. 15o -> 150)
    s = s.replaceAllMapped(RegExp(r'(\d)[oO]\b'), (m) => '${m[1]}0');
    s = s.replaceAllMapped(RegExp(r'\b[I|l](\d+)'), (m) => '1${m[1]}');

    // Clean up handwritten trailing dashes/equal signs: '150/-' or '150/=' -> '150'
    s = s.replaceAllMapped(RegExp(r'(\d+)\s*/[-=]'), (m) => '${m[1]}');

    return s;
  }

  /// Backward-compatible parseTotalAmount method
  static double? parseTotalAmount(String text) {
    return parse(text).extractedTotal;
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
}

