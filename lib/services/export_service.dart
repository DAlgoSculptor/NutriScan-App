import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/scan_result.dart';

class ExportService {
  /// Generate a PDF report from scan results
  static Future<File> generatePDFReport(ScanResult scanResult) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.green),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'NutriScan Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Food Ingredient Analysis',
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Scan Information
            _buildSection('Scan Information', [
              _buildInfoRow('Date & Time', scanResult.scanTime.toString().split('.')[0]),
              _buildInfoRow('Overall Risk Level', scanResult.overallRiskLevel),
              _buildInfoRow('Total Ingredients Found', '${scanResult.detectedIngredients.length}'),
              _buildInfoRow('Harmful Ingredients', '${scanResult.harmfulIngredients.length}'),
            ]),
            
            pw.SizedBox(height: 20),
            
            // Harmful Ingredients Section
            if (scanResult.harmfulIngredients.isNotEmpty) ...[
              _buildSection('⚠️ Harmful Ingredients Detected', 
                scanResult.harmfulIngredients.map((ingredient) => 
                  _buildIngredientInfo(ingredient)
                ).toList()
              ),
              pw.SizedBox(height: 20),
            ],
            
            // All Ingredients Section
            _buildSection('All Detected Ingredients', [
              pw.Wrap(
                spacing: 8,
                runSpacing: 4,
                children: scanResult.detectedIngredients.map((ingredient) {
                  final isHarmful = scanResult.harmfulIngredients.any(
                    (harmful) => harmful.matchesSearchTerm(ingredient),
                  );
                  
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: isHarmful ? PdfColors.red100 : PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      ingredient,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: isHarmful ? PdfColors.red800 : PdfColors.grey800,
                        fontWeight: isHarmful ? pw.FontWeight.bold : pw.FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
            
            pw.SizedBox(height: 30),
            
            // Disclaimer
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Important Disclaimer',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'This report is based on optical character recognition (OCR) and rule-based matching. While we strive for accuracy, this information should not replace professional medical advice. Always consult with healthcare professionals for personalized dietary recommendations.',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer
            pw.Spacer(),
            pw.Container(
              padding: const pw.EdgeInsets.only(top: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(width: 1, color: PdfColors.grey400),
                ),
              ),
              child: pw.Center(
                child: pw.Text(
                  'Generated by NutriScan • Empowering Healthier Food Choices',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
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
    
    buffer.writeln('🥗 NutriScan Report');
    buffer.writeln('═' * 40);
    buffer.writeln();
    
    // Scan Information
    buffer.writeln('📊 Scan Information');
    buffer.writeln('Date: ${scanResult.scanTime.toString().split('.')[0]}');
    buffer.writeln('Overall Risk: ${scanResult.overallRiskLevel}');
    buffer.writeln('Total Ingredients: ${scanResult.detectedIngredients.length}');
    buffer.writeln('Harmful Found: ${scanResult.harmfulIngredients.length}');
    buffer.writeln();
    
    // Harmful Ingredients
    if (scanResult.harmfulIngredients.isNotEmpty) {
      buffer.writeln('⚠️ Harmful Ingredients Detected');
      buffer.writeln('─' * 35);
      
      for (final ingredient in scanResult.harmfulIngredients) {
        buffer.writeln();
        buffer.writeln('🔴 ${ingredient.name} (${ingredient.riskLevel} Risk)');
        buffer.writeln('   Category: ${ingredient.category}');
        buffer.writeln('   ${ingredient.description}');
        
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
      
      buffer.write('${i + 1}. $ingredient');
      if (isHarmful) buffer.write(' ⚠️');
      buffer.writeln();
    }
    
    buffer.writeln();
    buffer.writeln('─' * 40);
    buffer.writeln('Generated by NutriScan');
    buffer.writeln('Empowering Healthier Food Choices');
    
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
        subject: 'NutriScan Report - ${scanResult.overallRiskLevel}',
        text: 'Food ingredient analysis report generated by NutriScan',
      );
    } catch (e) {
      throw Exception('Failed to generate PDF report: $e');
    }
  }

  /// Helper method to build PDF sections
  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green,
          ),
        ),
        pw.SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// Helper method to build info rows
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  /// Helper method to build ingredient information
  static pw.Widget _buildIngredientInfo(dynamic ingredient) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.red200),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.red50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  ingredient.riskLevel,
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                ingredient.name,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Category: ${ingredient.category}',
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            ingredient.description,
            style: const pw.TextStyle(fontSize: 11),
          ),
          if (ingredient.sideEffects.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Potential Side Effects:',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              ingredient.sideEffects.join(', '),
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
