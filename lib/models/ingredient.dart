import 'package:json_annotation/json_annotation.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  final String name;
  final List<String> aliases;
  @JsonKey(name: 'risk_level')
  final String riskLevel;
  final String category;
  final String description;
  @JsonKey(name: 'side_effects')
  final List<String> sideEffects;
  @JsonKey(name: 'found_in')
  final List<String> foundIn;

  const Ingredient({
    required this.name,
    required this.aliases,
    required this.riskLevel,
    required this.category,
    required this.description,
    required this.sideEffects,
    required this.foundIn,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  // Helper method to get risk level color
  String get riskLevelColor {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return '#FF3333';
      case 'moderate':
        return '#FF9500';
      case 'caution':
        return '#FFCC00';
      default:
        return '#4CAF50';
    }
  }

  // Helper method to check if ingredient matches a search term
  bool matchesSearchTerm(String searchTerm) {
    final term = searchTerm.toLowerCase().trim();
    if (term.isEmpty) return false;
    
    return name.toLowerCase().contains(term) ||
           aliases.any((alias) => alias.toLowerCase().contains(term));
  }
}
