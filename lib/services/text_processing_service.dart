class TextProcessingService {
  /// Clean and normalize extracted text
  static String cleanText(String text) {
    if (text.isEmpty) return text;

    // Remove extra whitespace and normalize
    String cleaned = text.trim();
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    // Fix common OCR errors
    cleaned = _fixCommonOCRErrors(cleaned);
    
    return cleaned;
  }

  /// Parse ingredients from cleaned text
  static List<String> parseIngredients(String text) {
    if (text.isEmpty) return [];

    // Clean the text first
    String cleaned = cleanText(text);
    
    // Remove common prefixes
    cleaned = _removeIngredientPrefixes(cleaned);
    
    // Split by common separators
    List<String> ingredients = _splitIngredients(cleaned);
    
    // Clean individual ingredients
    ingredients = ingredients.map((ingredient) => _cleanIndividualIngredient(ingredient)).toList();
    
    // Remove empty and invalid ingredients
    ingredients = ingredients.where((ingredient) => _isValidIngredient(ingredient)).toList();
    
    // Remove duplicates while preserving order
    ingredients = _removeDuplicates(ingredients);
    
    return ingredients;
  }

  /// Fix common OCR errors
  static String _fixCommonOCRErrors(String text) {
    // Common OCR mistakes and their corrections
    final ocrFixes = {
      // Number/letter confusion
      '0': 'o',
      '5': 's',
      '1': 'l',
      '8': 'B',
      // Common character mistakes
      'rn': 'm',
      'cl': 'd',
      'ii': 'll',
      // Common word mistakes
      'cane': 'came',
      'artificia1': 'artificial',
      'co1or': 'color',
      'f1avor': 'flavor',
    };

    String fixed = text;
    ocrFixes.forEach((wrong, correct) {
      fixed = fixed.replaceAll(wrong, correct);
    });

    return fixed;
  }

  /// Remove ingredient list prefixes
  static String _removeIngredientPrefixes(String text) {
    final prefixPatterns = [
      RegExp(r'^ingredients?\s*:?\s*', caseSensitive: false),
      RegExp(r'^contains?\s*:?\s*', caseSensitive: false),
      RegExp(r'^made with\s*:?\s*', caseSensitive: false),
      RegExp(r'^allergens?\s*:?\s*', caseSensitive: false),
    ];

    String cleaned = text;
    for (final pattern in prefixPatterns) {
      cleaned = cleaned.replaceFirst(pattern, '');
    }

    return cleaned.trim();
  }

  /// Split ingredients by various separators
  static List<String> _splitIngredients(String text) {
    // First try comma separation (most common)
    List<String> ingredients = text.split(',');
    
    // If we don't get multiple ingredients, try other separators
    if (ingredients.length == 1) {
      // Try semicolon
      ingredients = text.split(';');
      if (ingredients.length == 1) {
        // Try periods (but be careful not to split decimal numbers)
        ingredients = text.split(RegExp(r'\.(?!\d)'));
        if (ingredients.length == 1) {
          // Try parentheses as separators (less common)
          ingredients = text.split(RegExp(r'[()]+'));
        }
      }
    }

    return ingredients;
  }

  /// Clean individual ingredient strings
  static String _cleanIndividualIngredient(String ingredient) {
    // Remove leading/trailing whitespace
    String cleaned = ingredient.trim();
    
    // Remove common punctuation at the end
    cleaned = cleaned.replaceAll(RegExp(r'[.,;:!?]+\$'), '');
    
    // Remove parenthetical information that's not part of the ingredient name
    cleaned = _removeParentheticals(cleaned);
    
    // Remove percentage indicators
    cleaned = cleaned.replaceAll(RegExp(r'\s*\(\s*\d+%?\s*\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*\d+%?\s*\$'), '');
    
    // Remove numbers at the beginning (like "1. Sugar")
    cleaned = cleaned.replaceAll(RegExp(r'^\d+\.?\s*'), '');
    
    // Convert to proper case (first letter uppercase)
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1).toLowerCase();
    }
    
    return cleaned.trim();
  }

  /// Remove parenthetical information (but keep E-numbers)
  static String _removeParentheticals(String text) {
    // Keep E-numbers and similar codes
    if (RegExp(r'\bE\d+\b', caseSensitive: false).hasMatch(text)) {
      return text;
    }
    
    // Remove other parenthetical content
    return text.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
  }

  /// Check if an ingredient string is valid
  static bool _isValidIngredient(String ingredient) {
    if (ingredient.isEmpty) return false;
    if (ingredient.length < 2) return false;
    if (ingredient.length > 100) return false; // Probably not a single ingredient
    
    // Must contain at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(ingredient)) return false;
    
    // Exclude common non-ingredients
    final excludePatterns = [
      RegExp(r'^and\s*\$', caseSensitive: false),
      RegExp(r'^or\s*\$', caseSensitive: false),
      RegExp(r'^the\s*\$', caseSensitive: false),
      RegExp(r'^may contain\s*\$', caseSensitive: false),
      RegExp(r'^allergen\s*\$', caseSensitive: false),
      RegExp(r'^\d+\s*(g|mg|kg|oz|lb)\s*\$', caseSensitive: false),
    ];
    
    return !excludePatterns.any((pattern) => pattern.hasMatch(ingredient));
  }

  /// Remove duplicate ingredients while preserving order
  static List<String> _removeDuplicates(List<String> ingredients) {
    final seen = <String>{};
    final unique = <String>[];
    
    for (final ingredient in ingredients) {
      final normalized = ingredient.toLowerCase().trim();
      if (!seen.contains(normalized)) {
        seen.add(normalized);
        unique.add(ingredient);
      }
    }
    
    return unique;
  }

  /// Extract potential allergen information
  static List<String> extractAllergens(String text) {
    final allergenKeywords = [
      'milk', 'dairy', 'lactose',
      'eggs', 'egg',
      'fish', 'shellfish', 'crustaceans',
      'tree nuts', 'nuts', 'peanuts',
      'wheat', 'gluten',
      'soy', 'soybeans',
      'sesame',
    ];
    
    final found = <String>[];
    final lowerText = text.toLowerCase();
    
    for (final allergen in allergenKeywords) {
      if (lowerText.contains(allergen) && !found.contains(allergen)) {
        found.add(allergen);
      }
    }
    
    return found;
  }

  /// Estimate confidence in OCR results
  static double estimateOCRConfidence(String text) {
    if (text.isEmpty) return 0.0;
    
    double confidence = 1.0;
    
    // Penalize for too many numbers (might be nutritional info, not ingredients)
    final numberCount = RegExp(r'\d').allMatches(text).length;
    final totalChars = text.length;
    if (totalChars > 0) {
      final numberRatio = numberCount / totalChars;
      if (numberRatio > 0.3) confidence *= 0.7;
    }
    
    // Penalize for too many special characters
    final specialCharCount = RegExp(r'[^\w\s,.]').allMatches(text).length;
    if (totalChars > 0) {
      final specialCharRatio = specialCharCount / totalChars;
      if (specialCharRatio > 0.2) confidence *= 0.8;
    }
    
    // Reward for having common ingredient keywords
    final ingredientKeywords = ['sugar', 'salt', 'flour', 'water', 'oil'];
    bool hasIngredientKeywords = ingredientKeywords.any(
      (keyword) => text.toLowerCase().contains(keyword)
    );
    if (hasIngredientKeywords) confidence *= 1.2;
    
    return confidence.clamp(0.0, 1.0);
  }
}
