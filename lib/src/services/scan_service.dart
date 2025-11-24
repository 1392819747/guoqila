import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanItem {
  final String? name;
  final String? category;
  final String? expiryDate;
  final String? productionDate;
  final int? shelfLifeDays;
  final int quantity;

  ScanItem({
    this.name,
    this.category,
    this.expiryDate,
    this.productionDate,
    this.shelfLifeDays,
    this.quantity = 1,
  });

  factory ScanItem.fromJson(Map<String, dynamic> json) {
    return ScanItem(
      name: json['name'] as String?,
      category: json['category'] as String?,
      expiryDate: json['expiryDate'] as String?,
      productionDate: json['productionDate'] as String?,
      shelfLifeDays: json['shelfLifeDays'] as int?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class ScanResult {
  final List<ScanItem> items;
  final double confidence;

  ScanResult({
    this.items = const [],
    this.confidence = 0.0,
  });
  
  // Backwards compatibility getters for single item
  String? get text => items.isNotEmpty ? items.first.name : null;
  String? get category => items.isNotEmpty ? items.first.category : null;
  String? get expiryDate => items.isNotEmpty ? items.first.expiryDate : null;

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
        ?.map((e) => ScanItem.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
        
    return ScanResult(
      items: itemsList,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ScanService {
  // Use production domain for all environments
  static String get _backendUrl => 'https://bxgq.zhizhihu.cn';

  Future<ScanResult> scanImage(File imageFile, {String locale = 'zh'}) async {
    try {
      debugPrint('📸 Compressing image...');
      // Compress image to reduce size and token usage
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 1024, // Resize to max 1024px width/height
        minHeight: 1024,
        quality: 70, // 70% quality
      );
      
      if (compressedBytes == null) {
        throw Exception('Image compression failed');
      }

      final base64Image = base64Encode(compressedBytes);

      debugPrint('🌐 Calling backend API at $_backendUrl...');
      final response = await http.post(
        Uri.parse('$_backendUrl/api/v1/recognize'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': '9cec406282cf1ec58eb71640eeb90eb1', // TODO: Move to secure storage/config
        },
        body: jsonEncode({
          'image': base64Image,
          'locale': locale,
        }),
      ).timeout(
        const Duration(seconds: 60), // Increased timeout to 60s
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true && data['data'] != null) {
          debugPrint('✅ Recognition successful');
          return ScanResult.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          debugPrint('❌ Recognition failed: ${data['error']}');
          throw Exception('API Error: ${data['error']}');
        }
      } else {
        debugPrint('❌ API error: ${response.statusCode}');
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Scan error: $e');
      debugPrint('⚠️ Falling back to offline OCR...');
      return await performOfflineOCR(imageFile);
    }
  }

  Future<ScanResult> performOfflineOCR(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String text = recognizedText.text;
      await textRecognizer.close();

      if (text.isEmpty) return ScanResult();

      // Simple parsing logic for offline mode
      final lines = text.split('\n');
      String? name = lines.isNotEmpty ? lines.first : null;
      String? expiryDate;
      
      // Try to find date
      final dateRegex = RegExp(r'(\d{4})[./-](\d{1,2})[./-](\d{1,2})');
      for (final line in lines) {
        final match = dateRegex.firstMatch(line);
        if (match != null) {
          expiryDate = '${match.group(1)}-${match.group(2)!.padLeft(2, '0')}-${match.group(3)!.padLeft(2, '0')}';
          break;
        }
      }

      return ScanResult(
        items: [
          ScanItem(
            name: name,
            category: 'Food', // Default category
            expiryDate: expiryDate,
            quantity: 1,
          )
        ],
        confidence: 0.6, // Lower confidence for offline
      );
    } catch (e) {
      debugPrint('❌ Offline OCR failed: $e');
      return ScanResult();
    }
  }
}
