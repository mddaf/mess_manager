import 'package:flutter_test/flutter_test.dart';
import 'package:mess_manager/core/extensions.dart';
import 'package:mess_manager/data/services/receipt_parser.dart';

void main() {
  group('ReceiptParser OCR Tests', () {
    test('Extracts total amount from English receipt text', () {
      const sampleText = '''
      Bazar Super Shop
      Date: 2026-08-05
      Rice 5kg 450.00
      Oil 2L 320.00
      Total: 770.00
      Thank you for shopping!
      ''';

      final total = ReceiptParser.parseTotalAmount(sampleText);
      expect(total, equals(770.00));
    });

    test('Extracts total amount from Bangla receipt text with Bangla numerals', () {
      const sampleText = '''
      স্বপ্ন সুপার শপ
      চাল ৫ কেজি - ৪৫০.০০
      সয়াবিন তেল ২ লিটার - ৩২০.০০
      সর্বমোট: ৭৭০.০০ টাকা
      ''';

      final total = ReceiptParser.parseTotalAmount(sampleText);
      expect(total, equals(770.00));
    });
  });

  group('Core Extensions Tests', () {
    test('Formats double currency correctly', () {
      const amount = 1250.50;
      expect(amount.toCurrency(symbol: '৳'), equals('৳1,250.50'));
    });

    test('Converts Bangla and English numerals bidirectionally', () {
      const englishStr = '12345';
      const banglaStr = '১২৩৪৫';

      expect(englishStr.toBanglaNumerals(), equals(banglaStr));
      expect(banglaStr.toEnglishNumerals(), equals(englishStr));
    });
  });
}
