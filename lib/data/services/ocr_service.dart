import 'package:flutter/foundation.dart';

// Conditionally import ML Kit on mobile platforms
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'receipt_parser.dart';

class OcrService {
  TextRecognizer? _textRecognizer;

  OcrService() {
    if (!kIsWeb) {
      _textRecognizer = TextRecognizer();
    }
  }

  Future<OcrResult> processReceiptImage(String imagePath) async {
    if (kIsWeb || _textRecognizer == null) {
      return OcrResult(
        rawText: 'OCR not supported on web. Please enter amount manually.',
        confidence: 0.0,
      );
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _textRecognizer!.processImage(inputImage);

      return ReceiptParser.parse(recognizedText.text);
    } catch (e) {
      return OcrResult(
        rawText: 'OCR Error: ${e.toString()}',
        confidence: 0.0,
      );
    }
  }

  void dispose() {
    _textRecognizer?.close();
  }
}
