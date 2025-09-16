import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../theme/app_theme.dart';

class IngredientDetailCard extends StatefulWidget {
  final Ingredient ingredient;

  const IngredientDetailCard({
    super.key,
    required this.ingredient,
  });

  @override
  State<IngredientDetailCard> createState() => _IngredientDetailCardState();
}

class _IngredientDetailCardState extends State<IngredientDetailCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final riskColor = Color(int.parse(widget.ingredient.riskLevelColor.substring(1), radix: 16) + 0xFF000000);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: riskColor.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: riskColor.withOpacity(0.05),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Risk indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getRiskIcon(widget.ingredient.riskLevel),
                      color: riskColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Ingredient info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ingredient.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: riskColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.ingredient.riskLevel,
                                style: TextStyle(
                                  color: riskColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.ingredient.category,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Expand icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.mediumGray,
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded content
          if (_isExpanded) _buildExpandedContent(context, riskColor),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, Color riskColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Divider
            Container(
              height: 1,
              color: riskColor.withOpacity(0.2),
              margin: const EdgeInsets.only(bottom: 16),
            ),
            
            // Description
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.ingredient.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
              overflow: TextOverflow.clip,
              softWrap: true,
            ),
            const SizedBox(height: 12),
            
            // Side Effects
            if (widget.ingredient.sideEffects.isNotEmpty) ...[
              Text(
                'Potential Side Effects',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.ingredient.sideEffects.map((effect) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: riskColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      effect,
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            
            // Aliases
            if (widget.ingredient.aliases.isNotEmpty) ...[
              Text(
                'Also Known As',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.ingredient.aliases.join(', '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mediumGray,
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            
            // Commonly Found In
            if (widget.ingredient.foundIn.isNotEmpty) ...[
              Text(
                'Commonly Found In',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.ingredient.foundIn.join(', '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mediumGray,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return Icons.dangerous_rounded;
      case 'moderate':
        return Icons.warning_rounded;
      case 'caution':
        return Icons.info_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }
} 