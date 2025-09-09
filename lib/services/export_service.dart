import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/scan_result.dart';
import '../models/ingredient.dart';

class ExportService {
  /// Generate a professional PDF report from scan results
  static Future<File> generatePDFReport(ScanResult scanResult) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header with logo and title
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 24),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 3, color: PdfColors.green700),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'NutriScan',
                            style: pw.TextStyle(
                              fontSize: 28,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green700,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Food Ingredient Analysis Report',
                            style: pw.TextStyle(
                              fontSize: 16,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        width: 60,
                        height: 60,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green100,
                          borderRadius: pw.BorderRadius.all(pw.Radius.circular(30)),
                        ),
                        child: pw.Center(
                          child: pw.Icon(
                            pw.IconData(0xe069), // Scanner icon
                            color: PdfColors.green700,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 24),
            
            // Executive Summary
            _buildProfessionalSection('Executive Summary', [
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: _lightenPdfColor(_getRiskColor(scanResult.overallRiskLevel), 0.8),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(
                    color: _lightenPdfColor(_getRiskColor(scanResult.overallRiskLevel), 0.5),
                    width: 1,
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Overall Risk Assessment',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: _lightenPdfColor(_getRiskColor(scanResult.overallRiskLevel), 0.7),
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                          ),
                          child: pw.Icon(
                            _getRiskIcon(scanResult.overallRiskLevel),
                            color: _getRiskColor(scanResult.overallRiskLevel),
                            size: 24,
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                scanResult.overallRiskLevel,
                                style: pw.TextStyle(
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold,
                                  color: _getRiskColor(scanResult.overallRiskLevel),
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                _getRiskDescription(scanResult.overallRiskLevel),
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                children: [
                  _buildProfessionalStatCard('Total Ingredients', '${scanResult.detectedIngredients.length}', PdfColors.blue700),
                  pw.SizedBox(width: 16),
                  _buildProfessionalStatCard('Harmful Ingredients', '${scanResult.harmfulIngredients.length}', _getRiskColor(scanResult.overallRiskLevel)),
                  pw.SizedBox(width: 16),
                  _buildProfessionalStatCard('Scan Date', _formatDate(scanResult.scanTime), PdfColors.green700),
                ],
              ),
            ]),
            
            pw.SizedBox(height: 24),
            
            // Harmful Ingredients Section
            if (scanResult.harmfulIngredients.isNotEmpty) ...[
              _buildProfessionalSection('⚠️ Harmful Ingredients Detected', 
                <pw.Widget>[
                  ...scanResult.harmfulIngredients.map((ingredient) => 
                    _buildProfessionalIngredientCard(ingredient)
                  ).toList(),
                ]
              ),
              pw.SizedBox(height: 24),
            ],
            
            // All Ingredients Section
            _buildProfessionalSection('📋 All Detected Ingredients', 
              <pw.Widget>[
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: scanResult.detectedIngredients.map((ingredient) {
                    final isHarmful = scanResult.harmfulIngredients.any(
                      (harmful) => harmful.matchesSearchTerm(ingredient),
                    );
                    
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: isHarmful ? PdfColors.red100 : PdfColors.grey200,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(20)),
                        border: pw.Border.all(
                          color: isHarmful ? PdfColors.red300 : PdfColors.grey300,
                          width: 1,
                        ),
                      ),
                      child: pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          if (isHarmful) ...[
                            pw.Icon(
                              pw.IconData(0xe262), // Warning icon
                              color: PdfColors.red700,
                              size: 12,
                            ),
                            pw.SizedBox(width: 4),
                          ],
                          pw.Text(
                            ingredient,
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: isHarmful ? PdfColors.red800 : PdfColors.grey800,
                              fontWeight: isHarmful ? pw.FontWeight.bold : pw.FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ]
            ),
            
            pw.SizedBox(height: 30),
            
            // Methodology
            _buildProfessionalSection('🔬 Analysis Methodology', 
              <pw.Widget>[
                pw.Text(
                  'This report was generated using advanced optical character recognition (OCR) technology combined with a comprehensive database of harmful food ingredients. Our system analyzes ingredient lists to identify potential health risks based on scientific research and regulatory guidelines.',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '• Text extraction using Google ML Kit OCR',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      '• Ingredient parsing and normalization',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      '• Matching against database of 4000+ harmful substances',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      '• Risk categorization (High, Moderate, Caution, Safe)',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      '• Detailed health impact analysis',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ]
            ),
            
            pw.SizedBox(height: 30),
            
            // Disclaimer
            _buildProfessionalSection('⚠️ Important Disclaimer', 
              <pw.Widget>[
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(
                      color: PdfColors.grey300,
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '⚠️ Important Disclaimer',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'This report is based on optical character recognition (OCR) and rule-based matching. While we strive for accuracy, this information should not replace professional medical advice. Always consult with healthcare professionals for personalized dietary recommendations. The presence of harmful ingredients does not necessarily indicate immediate health risks, and their absence does not guarantee complete safety.',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ),
            
            // Footer
            pw.Spacer(),
            pw.Container(
              padding: const pw.EdgeInsets.only(top: 24),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(width: 1, color: PdfColors.grey400),
                ),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Generated by NutriScan',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Page 1 of 1',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Empowering Healthier Food Choices',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Save to temporary directory
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/nutriscan_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  /// Generate shareable text report
  static String generateTextReport(ScanResult scanResult) {
    final buffer = StringBuffer();
    
    buffer.writeln('🥗 NutriScan Professional Report');
    buffer.writeln('═' * 50);
    buffer.writeln();
    
    // Executive Summary
    buffer.writeln('📊 Executive Summary');
    buffer.writeln('─' * 20);
    buffer.writeln('Overall Risk: ${scanResult.overallRiskLevel}');
    buffer.writeln('Date: ${_formatDate(scanResult.scanTime)} at ${_formatTime(scanResult.scanTime)}');
    buffer.writeln('Total Ingredients: ${scanResult.detectedIngredients.length}');
    buffer.writeln('Harmful Ingredients Found: ${scanResult.harmfulIngredients.length}');
    buffer.writeln();
    
    // Risk Assessment
    buffer.writeln('🔍 Risk Assessment');
    buffer.writeln('─' * 18);
    buffer.writeln('${scanResult.overallRiskLevel}: ${_getRiskDescription(scanResult.overallRiskLevel)}');
    buffer.writeln();
    
    // Harmful Ingredients
    if (scanResult.harmfulIngredients.isNotEmpty) {
      buffer.writeln('⚠️ Harmful Ingredients Detected');
      buffer.writeln('─' * 35);
      
      for (final ingredient in scanResult.harmfulIngredients) {
        buffer.writeln();
        buffer.writeln('🔴 ${ingredient.name}');
        buffer.writeln('   Risk Level: ${ingredient.riskLevel}');
        buffer.writeln('   Category: ${ingredient.category}');
        buffer.writeln('   Description: ${ingredient.description}');
        
        if (ingredient.sideEffects.isNotEmpty) {
          buffer.writeln('   Side Effects: ${ingredient.sideEffects.join(', ')}');
        }
      }
      buffer.writeln();
    } else {
      buffer.writeln('✅ No harmful ingredients detected!');
      buffer.writeln();
    }
    
    // All Ingredients
    buffer.writeln('📋 All Detected Ingredients');
    buffer.writeln('─' * 30);
    for (int i = 0; i < scanResult.detectedIngredients.length; i++) {
      final ingredient = scanResult.detectedIngredients[i];
      final isHarmful = scanResult.harmfulIngredients.any(
        (harmful) => harmful.matchesSearchTerm(ingredient),
      );
      
      buffer.write('${(i + 1).toString().padLeft(2)}. $ingredient');
      if (isHarmful) buffer.write(' ⚠️');
      buffer.writeln();
    }
    
    buffer.writeln();
    buffer.writeln('─' * 50);
    buffer.writeln('🔬 Analysis Methodology');
    buffer.writeln('This report was generated using advanced OCR technology combined with a comprehensive');
    buffer.writeln('database of harmful food ingredients. Our system analyzes ingredient lists to');
    buffer.writeln('identify potential health risks based on scientific research.');
    buffer.writeln();
    buffer.writeln('⚠️ Important Disclaimer');
    buffer.writeln('This information should not replace professional medical advice. Always consult');
    buffer.writeln('with healthcare professionals for personalized dietary recommendations.');
    buffer.writeln();
    buffer.writeln('Generated by NutriScan • Empowering Healthier Food Choices');
    
    return buffer.toString();
  }

  /// Share scan results as text
  static Future<void> shareTextReport(ScanResult scanResult) async {
    final textReport = generateTextReport(scanResult);
    
    await Share.share(
      textReport,
      subject: 'NutriScan Report - ${scanResult.overallRiskLevel}',
    );
  }

  /// Share scan results as PDF
  static Future<void> sharePDFReport(ScanResult scanResult) async {
    try {
      final pdfFile = await generatePDFReport(scanResult);
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: 'NutriScan Professional Report - ${scanResult.overallRiskLevel}',
        text: 'Food ingredient analysis report generated by NutriScan',
      );
    } catch (e) {
      throw Exception('Failed to generate PDF report: $e');
    }
  }

  /// Helper method to build professional PDF sections
  static pw.Widget _buildProfessionalSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 2, color: PdfColors.green300),
            ),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
        ),
        pw.SizedBox(height: 16),
        ...children,
      ],
    );
  }

  /// Helper method to build professional stat cards
  static pw.Widget _buildProfessionalStatCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _lightenPdfColor(color, 0.8),
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(
            color: _lightenPdfColor(color, 0.6),
            width: 1,
          ),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build professional ingredient cards
  static pw.Widget _buildProfessionalIngredientCard(Ingredient ingredient) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.red200),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
        color: PdfColors.red50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: _getRiskColor(ingredient.riskLevel),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Text(
                  ingredient.riskLevel,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Text(
                  ingredient.name,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Category: ${ingredient.category}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  ingredient.description,
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey800,
                    height: 1.4,
                  ),
                ),
                if (ingredient.sideEffects.isNotEmpty) ...[
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Potential Side Effects:',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: ingredient.sideEffects.map((effect) {
                      return pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.red100,
                          borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                          border: pw.Border.all(
                            color: PdfColors.red300,
                            width: 0.5,
                          ),
                        ),
                        child: pw.Text(
                          effect,
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.red800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to get risk color
  static PdfColor _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
      case 'high risk':
        return PdfColors.red700;
      case 'moderate':
      case 'moderate risk':
        return PdfColors.orange700;
      case 'caution':
        return PdfColors.yellow700;
      default:
        return PdfColors.green700;
    }
  }

  /// Helper method to get risk icon
  static pw.IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high risk':
        return pw.IconData(0xe262); // Dangerous icon
      case 'moderate risk':
        return pw.IconData(0xe002); // Warning icon
      case 'caution':
        return pw.IconData(0xe88e); // Info icon
      default:
        return pw.IconData(0xe86c); // Check circle icon
    }
  }

  /// Helper method to get risk description
  static String _getRiskDescription(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high risk':
        return 'Multiple high-risk ingredients detected - Avoid consumption';
      case 'moderate risk':
        return 'Some concerning ingredients found - Consume with caution';
      case 'caution':
        return 'Minor ingredients of concern - Generally safe';
      default:
        return 'No harmful ingredients detected - Safe for consumption';
    }
  }

  /// Helper method to format date
  static String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  /// Helper method to format time
  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Helper method to lighten PDF color
  static PdfColor _lightenPdfColor(PdfColor color, double factor) {
    // Simple implementation to lighten a color by mixing with white
    final r = (color.red + (255 - color.red) * factor).toInt().clamp(0, 255);
    final g = (color.green + (255 - color.green) * factor).toInt().clamp(0, 255);
    final b = (color.blue + (255 - color.blue) * factor).toInt().clamp(0, 255);
    return PdfColor(r / 255, g / 255, b / 255);
  }
}