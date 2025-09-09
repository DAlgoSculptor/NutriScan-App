import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import '../services/text_processing_service.dart';
import '../services/export_service.dart';
import '../services/ingredient_database_service.dart';
import '../models/scan_result.dart';
import '../theme/app_theme.dart';
import '../widgets/scan_result_card.dart';
import '../widgets/loading_animation.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  ScanResult? _scanResult;
  bool _isProcessing = false;
  String _processingStep = '';

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await IngredientDatabaseService.loadDatabase();
    } catch (e) {
      _showErrorDialog('Failed to load ingredient database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ingredients'),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          if (_scanResult != null && !_isProcessing)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              onPressed: _generatePDFReport,
              tooltip: 'Generate PDF Report',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions Card
            _buildInstructionsCard(),
            const SizedBox(height: 24),
            
            // Image Selection Buttons
            _buildImageSelectionButtons(),
            const SizedBox(height: 24),
            
            // Selected Image Display
            if (_selectedImage != null) _buildSelectedImage(),
            
            // Processing Indicator
            if (_isProcessing) _buildProcessingIndicator(),
            
            // Scan Results
            if (_scanResult != null && !_isProcessing) _buildScanResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline, 
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'How to Scan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(1, 'Take a clear photo of the ingredient label', Icons.camera_alt_rounded),
            _buildInstructionStep(2, 'Ensure good lighting and focus', Icons.light_mode_rounded),
            _buildInstructionStep(3, 'Wait for analysis to complete', Icons.hourglass_bottom_rounded),
            _buildInstructionStep(4, 'Review harmful ingredients found', Icons.visibility_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, color: AppTheme.mediumGray, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelectionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_rounded, size: 24),
            label: const Text('Take Photo', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_rounded, size: 24),
            label: const Text('Choose from Gallery', style: TextStyle(fontSize: 18)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(
                color: AppTheme.primaryGreen,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedImage() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.image_rounded, 
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Selected Image',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processImage,
                icon: const Icon(Icons.analytics_rounded, size: 24),
                label: const Text('Analyze Ingredients', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const LoadingAnimation(size: 60),
            const SizedBox(height: 24),
            Text(
              'Processing Image...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _processingStep,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              backgroundColor: AppTheme.lightGray,
              color: AppTheme.primaryGreen,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.analytics_rounded, 
                color: AppTheme.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Scan Results',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _scanAnother,
              tooltip: 'Scan Another Product',
            ),
          ],
        ),
        const SizedBox(height: 20),
        ScanResultCard(scanResult: _scanResult!),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareResults,
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share Results'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _generatePDFReport,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('PDF Report'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _scanResult = null; // Clear previous results
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _processingStep = 'Extracting text from image...';
    });

    try {
      // Step 1: Real OCR Text Extraction
      final extractedText = await OCRService.extractIngredientsText(_selectedImage!);
      
      setState(() {
        _processingStep = 'Processing and cleaning text...';
      });
      
      // Step 2: Text Processing
      final cleanedText = TextProcessingService.cleanText(extractedText);
      final ingredients = TextProcessingService.parseIngredients(cleanedText);
      
      setState(() {
        _processingStep = 'Analyzing harmful ingredients...';
      });
      
      // Step 3: Harmful Ingredient Detection
      final harmfulIngredients = IngredientDatabaseService.findHarmfulIngredients(ingredients);
      
      setState(() {
        _processingStep = 'Generating results...';
      });
      
      // Step 4: Create Scan Result
      final scanResult = ScanResult(
        extractedText: extractedText,
        detectedIngredients: ingredients,
        harmfulIngredients: harmfulIngredients,
        scanTime: DateTime.now(),
        imagePath: _selectedImage!.path,
      );
      
      setState(() {
        _scanResult = scanResult;
        _isProcessing = false;
        _processingStep = '';
      });
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _processingStep = '';
      });
      _showErrorDialog('Failed to process image: $e');
    }
  }

  void _shareResults() async {
    if (_scanResult == null) return;

    try {
      // Show share options dialog
      final result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Share Report'),
            content: const Text('Choose how you\'d like to share your scan results:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('text'),
                child: const Text('Text Report'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('pdf'),
                child: const Text('PDF Report'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (result != null) {
        if (result == 'text') {
          await ExportService.shareTextReport(_scanResult!);
        } else if (result == 'pdf') {
          await ExportService.sharePDFReport(_scanResult!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share report: $e'),
            backgroundColor: AppTheme.moderateRisk,
          ),
        );
      }
    }
  }

  void _generatePDFReport() async {
    if (_scanResult == null) return;

    try {
      final pdfFile = await ExportService.generatePDFReport(_scanResult!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF report generated successfully!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
      
      // Optionally open the PDF or share it
      await ExportService.sharePDFReport(_scanResult!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF report: $e'),
            backgroundColor: AppTheme.moderateRisk,
          ),
        );
      }
    }
  }

  void _scanAnother() {
    setState(() {
      _selectedImage = null;
      _scanResult = null;
      _isProcessing = false;
      _processingStep = '';
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}