import 'ingredient.dart';

class ScanResult {
  final String extractedText;
  final List<String> detectedIngredients;
  final List<Ingredient> harmfulIngredients;
  final DateTime scanTime;
  final String? imagePath;

  const ScanResult({
    required this.extractedText,
    required this.detectedIngredients,
    required this.harmfulIngredients,
    required this.scanTime,
    this.imagePath,
  });

  // Calculate overall risk level based on harmful ingredients found
  String get overallRiskLevel {
    if (harmfulIngredients.isEmpty) return 'Safe';
    
    bool hasHigh = harmfulIngredients.any((ing) => ing.riskLevel.toLowerCase() == 'high');
    bool hasModerate = harmfulIngredients.any((ing) => ing.riskLevel.toLowerCase() == 'moderate');
    
    if (hasHigh) return 'High Risk';
    if (hasModerate) return 'Moderate Risk';
    return 'Caution';
  }

  // Get risk level color
  String get overallRiskColor {
    switch (overallRiskLevel) {
      case 'High Risk':
        return '#FF3333';
      case 'Moderate Risk':
        return '#FF9500';
      case 'Caution':
        return '#FFCC00';
      default:
        return '#4CAF50';
    }
  }

  // Generate summary text for sharing
  String generateSummary() {
    final buffer = StringBuffer();
    buffer.writeln('NutriScan Results');
    buffer.writeln('Scan Date: ${scanTime.toString().split('.')[0]}');
    buffer.writeln('Overall Risk: $overallRiskLevel');
    buffer.writeln('');
    
    if (harmfulIngredients.isEmpty) {
      buffer.writeln('✅ No harmful ingredients detected!');
    } else {
      buffer.writeln('⚠️ Harmful Ingredients Found:');
      for (final ingredient in harmfulIngredients) {
        buffer.writeln('• ${ingredient.name} (${ingredient.riskLevel} Risk)');
        buffer.writeln('  ${ingredient.description}');
        buffer.writeln('');
      }
    }
    
    buffer.writeln('Total ingredients detected: ${detectedIngredients.length}');
    return buffer.toString();
  }
}
