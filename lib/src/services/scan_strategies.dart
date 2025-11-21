import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart'; // Disabled for Simulator support
import 'scan_service.dart';

class MLKitStrategy implements ScanStrategy {
  @override
  bool get isSupported => true; // Assuming we are on mobile

  @override
  Future<ScanResult> scan(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    
    // Configure for Chinese + Latin text recognition
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.chinese,  // 关键修改：支持中文
    );
    
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      if (recognizedText.text.isNotEmpty) {
        return ScanResult(
          text: recognizedText.text,
          confidence: 0.8,
        );
      }
    } finally {
      textRecognizer.close();
    }

    return ScanResult();
  }
}

class TesseractStrategy implements ScanStrategy {
  @override
  bool get isSupported => false; // Disabled

  @override
  Future<ScanResult> scan(File imageFile) async {
    // Tesseract is disabled to allow Simulator builds (architecture mismatch)
    return ScanResult();
  }
}

// Placeholder for HMS Strategy
class HMSStrategy implements ScanStrategy {
  @override
  bool get isSupported => false; // Need to implement detection logic

  @override
  Future<ScanResult> scan(File imageFile) async {
    // TODO: Implement HMS ML Kit logic
    return ScanResult();
  }
}
