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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Risk Header
            _buildRiskHeader(context),
            const SizedBox(height: 20),
            
            // Summary Stats
            _buildSummaryStats(context),
            const SizedBox(height: 20),
            
            // Harmful Ingredients List
            if (scanResult.harmfulIngredients.isNotEmpty) ...[
              _buildHarmfulIngredientsSection(context),
              const SizedBox(height: 20),
            ],
            
            // All Detected Ingredients
            _buildAllIngredientsSection(context),
            const SizedBox(height: 20),
            
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            riskColor.withOpacity(0.15),
            riskColor.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: riskColor.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: riskColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getRiskIcon(scanResult.overallRiskLevel),
              color: riskColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Risk Assessment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.mediumGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scanResult.overallRiskLevel,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getRiskDescription(scanResult.overallRiskLevel),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: riskColor.withOpacity(0.9),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.7),
          width: 1,
        ),
      ),
      child: Row(
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
          const SizedBox(width: 16),
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
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              context,
              'Scan Time',
              _formatTime(scanResult.scanTime),
              Icons.access_time_rounded,
              AppTheme.accentGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, 
                       IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.moderateRisk.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppTheme.moderateRisk, size: 24),
              const SizedBox(width: 12),
              Text(
                'Harmful Ingredients Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.moderateRisk,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.moderateRisk.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${scanResult.harmfulIngredients.length} Items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.moderateRisk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scanResult.harmfulIngredients.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.list_rounded, color: AppTheme.primaryGreen, size: 24),
              const SizedBox(width: 12),
              Text(
                'All Detected Ingredients',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${scanResult.detectedIngredients.length} Items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightGray.withOpacity(0.7),
              width: 1,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: scanResult.detectedIngredients.map((ingredient) {
                  final isHarmful = scanResult.harmfulIngredients.any(
                    (harmful) => harmful.matchesSearchTerm(ingredient),
                  );
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isHarmful 
                          ? AppTheme.moderateRisk.withOpacity(0.2) 
                          : AppTheme.lightGray.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isHarmful 
                            ? AppTheme.moderateRisk.withOpacity(0.4) 
                            : AppTheme.lightGray.withOpacity(0.7),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isHarmful) ...[
                          Icon(
                            Icons.warning_rounded,
                            color: AppTheme.moderateRisk,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                        ],
                        SizedBox(
                          width: 200, // Limit width for overflow handling
                          child: Text(
                            ingredient,
                            style: TextStyle(
                              fontSize: 13,
                              color: isHarmful 
                                  ? AppTheme.moderateRisk 
                                  : AppTheme.mediumGray,
                              fontWeight: isHarmful ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: AppTheme.mediumGray, size: 20),
              const SizedBox(width: 8),
              Text(
                'Scan Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.mediumGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(context, Icons.calendar_today_rounded, 'Scan Date', 
              _formatDate(scanResult.scanTime)),
          _buildDetailRow(context, Icons.access_time_rounded, 'Scan Time', 
              _formatTime(scanResult.scanTime)),
          _buildDetailRow(context, Icons.speed_rounded, 'Processing Time', '< 10 seconds'),
          _buildDetailRow(context, Icons.check_circle_outline_rounded, 'Confidence', 'High'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.mediumGray, size: 18),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
              overflow: TextOverflow.ellipsis,
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

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}