import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/feature_card.dart';
import '../widgets/stats_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader(context),
              const SizedBox(height: 24),
              
              // Hero Section
              _buildHeroCard(context),
              const SizedBox(height: 24),
              
              // Quick Stats
              _buildQuickStats(context),
              const SizedBox(height: 24),
              
              // Features Section
              _buildFeaturesSection(context),
              const SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.mediumGray,
          ),
        ),
        Text(
          'NutriScan',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your smart companion for food safety',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.mediumGray,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.scanner,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan & Analyze',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ingredients in seconds',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Simply point your camera at any food product label and let NutriScan identify harmful ingredients for you.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'Ingredients',
            value: '4000+',
            subtitle: 'Harmful substances tracked',
            icon: Icons.warning_rounded,
            color: AppTheme.moderateRisk,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            title: 'Categories',
            value: '8',
            subtitle: 'Different types covered',
            icon: Icons.category_rounded,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            FeatureCard(
              icon: Icons.camera_alt_rounded,
              title: 'Smart OCR Scanning',
              description: 'Advanced text recognition to extract ingredients from any food label',
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 12),
            FeatureCard(
              icon: Icons.health_and_safety_rounded,
              title: 'Health Risk Analysis',
              description: 'Instant identification of harmful substances and their health impacts',
              color: AppTheme.moderateRisk,
            ),
            const SizedBox(height: 12),
            FeatureCard(
              icon: Icons.share_rounded,
              title: 'Export & Share',
              description: 'Generate reports and share results with family and friends',
              color: AppTheme.accentGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to scan screen
              Navigator.of(context).pushNamed('/scan');
            },
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Start Scanning'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/about');
                },
                icon: const Icon(Icons.info_outline_rounded),
                label: const Text('Learn More'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/contact');
                },
                icon: const Icon(Icons.contact_support_rounded),
                label: const Text('Contact Us'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}