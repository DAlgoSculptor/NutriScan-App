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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions Card
            _buildInstructionsCard(),
            const SizedBox(height: 20),
            
            // Image Selection Buttons
            _buildImageSelectionButtons(),
            const SizedBox(height: 20),
            
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'How to Scan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(1, 'Take a clear photo of the ingredient label'),
            _buildInstructionStep(2, 'Ensure good lighting and focus'),
            _buildInstructionStep(3, 'Wait for analysis to complete'),
            _buildInstructionStep(4, 'Review harmful ingredients found'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
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
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedImage() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Image',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processImage,
                icon: const Icon(Icons.analytics_rounded),
                label: const Text('Analyze Ingredients'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const LoadingAnimation(),
            const SizedBox(height: 16),
            Text(
              'Processing Image...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _processingStep,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
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
        Text(
          'Scan Results',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ScanResultCard(scanResult: _scanResult!),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareResults,
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _scanAnother,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Scan Another'),
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
