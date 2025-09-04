import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ingredient.dart';

class IngredientDatabaseService {
  static List<Ingredient> _harmfulIngredients = [];
  static bool _isLoaded = false;

  /// Load harmful ingredients database from JSON file
  static Future<void> loadDatabase() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/harmful_ingredients.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> ingredientsJson = jsonData['harmful_ingredients'];

      _harmfulIngredients = ingredientsJson
          .map((json) => Ingredient.fromJson(json))
          .toList();

      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load ingredients database: $e');
    }
  }

  /// Get all harmful ingredients
  static List<Ingredient> getAllIngredients() {
    if (!_isLoaded) {
      throw Exception('Database not loaded. Call loadDatabase() first.');
    }
    return List.unmodifiable(_harmfulIngredients);
  }

  /// Search for harmful ingredients in given text
  static List<Ingredient> findHarmfulIngredients(List<String> ingredients) {
    if (!_isLoaded) return [];

    final List<Ingredient> found = [];
    final Set<String> foundNames = {}; // Prevent duplicates

    for (final ingredient in ingredients) {
      for (final harmful in _harmfulIngredients) {
        if (!foundNames.contains(harmful.name) && 
            harmful.matchesSearchTerm(ingredient)) {
          found.add(harmful);
          foundNames.add(harmful.name);
        }
      }
    }

    // Sort by risk level (High -> Moderate -> Caution)
    found.sort((a, b) {
      const riskOrder = {'High': 0, 'Moderate': 1, 'Caution': 2};
      final aRisk = riskOrder[a.riskLevel] ?? 3;
      final bRisk = riskOrder[b.riskLevel] ?? 3;
      return aRisk.compareTo(bRisk);
    });

    return found;
  }

  /// Get ingredients by risk level
  static List<Ingredient> getIngredientsByRiskLevel(String riskLevel) {
    if (!_isLoaded) return [];
    
    return _harmfulIngredients
        .where((ingredient) => ingredient.riskLevel.toLowerCase() == riskLevel.toLowerCase())
        .toList();
  }

  /// Get ingredients by category
  static List<Ingredient> getIngredientsByCategory(String category) {
    if (!_isLoaded) return [];
    
    return _harmfulIngredients
        .where((ingredient) => ingredient.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Search ingredients by name or alias
  static List<Ingredient> searchIngredients(String query) {
    if (!_isLoaded || query.trim().isEmpty) return [];

    return _harmfulIngredients
        .where((ingredient) => ingredient.matchesSearchTerm(query))
        .toList();
  }

  /// Get all categories
  static List<String> getAllCategories() {
    if (!_isLoaded) return [];
    
    return _harmfulIngredients
        .map((ingredient) => ingredient.category)
        .toSet()
        .toList()
        ..sort();
  }

  /// Get statistics
  static Map<String, int> getStatistics() {
    if (!_isLoaded) return {};

    final stats = <String, int>{};
    stats['total'] = _harmfulIngredients.length;
    
    for (final ingredient in _harmfulIngredients) {
      final key = '${ingredient.riskLevel.toLowerCase()}_risk';
      stats[key] = (stats[key] ?? 0) + 1;
    }

    return stats;
  }
}
