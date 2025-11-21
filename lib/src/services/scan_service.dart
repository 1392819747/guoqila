import 'dart:io';
import 'package:flutter/foundation.dart';
import 'scan_strategies.dart';

class ScanResult {
  final String? text;
  final double confidence;

  ScanResult({this.text, this.confidence = 0.0});
}

abstract class ScanStrategy {
  Future<ScanResult> scan(File imageFile);
  bool get isSupported;
}

class ScanService {
  late ScanStrategy _strategy;

  ScanService() {
    _initStrategy();
  }

  void _initStrategy() {
    if (Platform.isAndroid || Platform.isIOS) {
      // TODO: Add logic to detect HarmonyOS if specific plugin is available
      // For now, default to ML Kit for mobile
      _strategy = MLKitStrategy();
    } else {
      _strategy = TesseractStrategy();
    }
  }

  Future<ScanResult> scanImage(File imageFile) async {
    try {
      if (_strategy.isSupported) {
        return await _strategy.scan(imageFile);
      }
    } catch (e) {
      debugPrint('Primary strategy failed: $e');
    }
    
    // Fallback
    if (_strategy is! TesseractStrategy) {
      debugPrint('Falling back to Tesseract');
      return await TesseractStrategy().scan(imageFile);
    }
    
    return ScanResult();
  }
}
