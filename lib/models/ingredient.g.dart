// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ingredient _$IngredientFromJson(Map<String, dynamic> json) => Ingredient(
  name: json['name'] as String,
  aliases: (json['aliases'] as List<dynamic>).map((e) => e as String).toList(),
  riskLevel: json['risk_level'] as String,
  category: json['category'] as String,
  description: json['description'] as String,
  sideEffects:
      (json['side_effects'] as List<dynamic>).map((e) => e as String).toList(),
  foundIn: (json['found_in'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'name': instance.name,
      'aliases': instance.aliases,
      'risk_level': instance.riskLevel,
      'category': instance.category,
      'description': instance.description,
      'side_effects': instance.sideEffects,
      'found_in': instance.foundIn,
    };
