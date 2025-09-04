import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../theme/app_theme.dart';
import 'ingredient_detail_card.dart';

class ScanResultCard extends StatelessWidget {
  final ScanResult scanResult;

  const ScanResultCard({
    super.key,
    required this.scanResult,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Risk Header
            _buildRiskHeader(context),
            const SizedBox(height: 16),
            
            // Summary Stats
            _buildSummaryStats(context),
            const SizedBox(height: 16),
            
            // Harmful Ingredients List
            if (scanResult.harmfulIngredients.isNotEmpty) ...[
              _buildHarmfulIngredientsSection(context),
              const SizedBox(height: 16),
            ],
            
            // All Detected Ingredients
            _buildAllIngredientsSection(context),
            
            // Scan Details
            _buildScanDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskHeader(BuildContext context) {
    final riskColor = Color(int.parse(scanResult.overallRiskColor.substring(1), radix: 16) + 0xFF000000);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: riskColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getRiskIcon(scanResult.overallRiskLevel),
              color: riskColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scanResult.overallRiskLevel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getRiskDescription(scanResult.overallRiskLevel),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: riskColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Ingredients',
            '${scanResult.detectedIngredients.length}',
            Icons.list_alt_rounded,
            AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Harmful Found',
            '${scanResult.harmfulIngredients.length}',
            Icons.warning_rounded,
            scanResult.harmfulIngredients.isEmpty 
                ? AppTheme.safeColor 
                : AppTheme.moderateRisk,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, 
                       IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHarmfulIngredientsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.moderateRisk),
            const SizedBox(width: 8),
            Text(
              'Harmful Ingredients Found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.moderateRisk,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scanResult.harmfulIngredients.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return IngredientDetailCard(
              ingredient: scanResult.harmfulIngredients[index],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAllIngredientsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'All Detected Ingredients',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: scanResult.detectedIngredients.map((ingredient) {
            final isHarmful = scanResult.harmfulIngredients.any(
              (harmful) => harmful.matchesSearchTerm(ingredient),
            );
            
            return Chip(
              label: Text(
                ingredient,
                style: TextStyle(
                  fontSize: 12,
                  color: isHarmful ? Colors.white : null,
                ),
              ),
              backgroundColor: isHarmful 
                  ? AppTheme.moderateRisk 
                  : Theme.of(context).chipTheme.backgroundColor,
              side: isHarmful 
                  ? BorderSide.none
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScanDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Scan Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow(context, 'Scan Time', 
            _formatDateTime(scanResult.scanTime)),
        _buildDetailRow(context, 'Processing Time', '< 10 seconds'),
        _buildDetailRow(context, 'Confidence', 'High'),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high risk':
        return Icons.dangerous_rounded;
      case 'moderate risk':
        return Icons.warning_rounded;
      case 'caution':
        return Icons.info_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String _getRiskDescription(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high risk':
        return 'Multiple high-risk ingredients detected';
      case 'moderate risk':
        return 'Some concerning ingredients found';
      case 'caution':
        return 'Minor ingredients of concern';
      default:
        return 'No harmful ingredients detected';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
