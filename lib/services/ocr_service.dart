import 'dart:io';
import 'dart:ui' as ui;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OCRService {
  static final _textRecognizer = TextRecognizer();

  /// Extract text from an image file
  static Future<String> extractTextFromImage(File imageFile) async {
    try {
      // Preprocess the image for better OCR results
      final processedImage = await _preprocessImage(imageFile);
      final inputImage = InputImage.fromFile(processedImage);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      return recognizedText.text;
    } catch (e) {
      throw Exception('Error extracting text: $e');
    }
  }

  /// Extract text and try to identify ingredient section
  static Future<String> extractIngredientsText(File imageFile) async {
    try {
      // Preprocess the image for better OCR results
      final processedImage = await _preprocessImage(imageFile);
      final inputImage = InputImage.fromFile(processedImage);
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

  /// Preprocess image to improve OCR accuracy
  static Future<File> _preprocessImage(File imageFile) async {
    try {
      // Read the image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return imageFile;
      
      // Apply preprocessing steps
      var processedImage = image;
      
      // 1. Resize if too large (improves processing speed)
      if (processedImage.width > 1024 || processedImage.height > 1024) {
        processedImage = img.copyResize(processedImage, width: 1024, height: 1024, maintainAspect: true);
      }
      
      // 2. Convert to grayscale
      processedImage = img.grayscale(processedImage);
      
      // 3. Apply contrast enhancement
      processedImage = img.adjustColor(processedImage, contrast: 1.2);
      
      // 4. Apply thresholding for better text separation
      // Convert to binary image using threshold
      processedImage = img.copyResize(processedImage, width: processedImage.width, height: processedImage.height);
      for (int y = 0; y < processedImage.height; y++) {
        for (int x = 0; x < processedImage.width; x++) {
          final pixel = processedImage.getPixel(x, y);
          // Extract RGB values correctly using image package methods
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;
          final luminance = (0.299 * r + 0.587 * g + 0.114 * b).round();
          // Create new pixel values (0-255 range)
          final newR = luminance < 128 ? 0 : 255;
          final newG = luminance < 128 ? 0 : 255;
          final newB = luminance < 128 ? 0 : 255;
          processedImage.setPixelRgba(x, y, newR, newG, newB, 255);
        }
      }
      
      // Save processed image to temporary file
      final processedBytes = img.encodePng(processedImage);
      final tempDir = await Directory.systemTemp.createTemp('ocr_processed');
      final processedFile = File('${tempDir.path}/processed_image.png');
      await processedFile.writeAsBytes(processedBytes);
      
      return processedFile;
    } catch (e) {
      // If preprocessing fails, return original image
      return imageFile;
    }
  }
}
