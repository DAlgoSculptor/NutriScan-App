import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static final _textRecognizer = TextRecognizer();

  /// Extract text from an image file
  static Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      return recognizedText.text;
    } catch (e) {
      throw Exception('Error extracting text: $e');
    }
  }

  /// Extract text and try to identify ingredient section
  static Future<String> extractIngredientsText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Try to find ingredient section
      String fullText = recognizedText.text;
      String ingredientSection = _findIngredientSection(fullText);
      
      return ingredientSection.isNotEmpty ? ingredientSection : fullText;
    } catch (e) {
      throw Exception('Error extracting ingredients text: $e');
    }
  }

  /// Find ingredient section in the extracted text
  static String _findIngredientSection(String text) {
    final lines = text.split('\n').map((line) => line.trim()).toList();
    
    // Common ingredient section indicators
    final ingredientKeywords = [
      'ingredients',
      'ingredient',
      'contains',
      'allergens',
      'may contain',
    ];
    
    int startIndex = -1;
    
    // Find line that contains ingredient keyword
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      for (final keyword in ingredientKeywords) {
        if (line.contains(keyword)) {
          startIndex = i;
          break;
        }
      }
      if (startIndex != -1) break;
    }
    
    if (startIndex == -1) return text; // Return full text if no ingredient section found
    
    // Extract from ingredient line to end or until we find a new section
    final ingredientLines = <String>[];
    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i];
      
      // Stop if we hit nutritional info or other sections
      if (_isNewSection(line.toLowerCase()) && i > startIndex) {
        break;
      }
      
      ingredientLines.add(line);
    }
    
    return ingredientLines.join(' ').trim();
  }

  /// Check if line indicates a new section (not ingredients)
  static bool _isNewSection(String line) {
    final sectionKeywords = [
      'nutrition',
      'nutritional',
      'values',
      'energy',
      'calories',
      'protein',
      'fat',
      'carbohydrate',
      'sugar',
      'salt',
      'sodium',
      'directions',
      'instructions',
      'storage',
      'warning',
      'allergen',
    ];
    
    return sectionKeywords.any((keyword) => line.startsWith(keyword));
  }

  /// Dispose resources
  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
