import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/feature_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About NutriScan'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            _buildHeroSection(context),
            const SizedBox(height: 24),
            
            // Vision Section
            _buildVisionSection(context),
            const SizedBox(height: 24),
            
            // Mission Section
            _buildMissionSection(context),
            const SizedBox(height: 24),
            
            // How It Works
            _buildHowItWorksSection(context),
            const SizedBox(height: 24),
            
            // Impact Section
            _buildImpactSection(context),
            const SizedBox(height: 24),
            
            // Future Plans
            _buildFuturePlansSection(context),
            const SizedBox(height: 24),
            
            // Team Section
            _buildTeamSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'NutriScan',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Empowering Healthier Food Choices',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'NutriScan is your intelligent companion in making informed food choices by instantly identifying harmful ingredients in packaged foods.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVisionSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.visibility_rounded,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Our Vision',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'To create a world where everyone has access to transparent, easy-to-understand information about the food they consume, empowering people to make healthier choices for themselves and their families.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: AppTheme.accentGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Our Mission',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'NutriScan democratizes food safety information by leveraging cutting-edge technology to:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            _buildMissionPoint(context, 'Instantly identify harmful ingredients in packaged foods'),
            _buildMissionPoint(context, 'Provide clear explanations of health risks and side effects'),
            _buildMissionPoint(context, 'Educate consumers about food additives and preservatives'),
            _buildMissionPoint(context, 'Promote transparency in the food industry'),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTheme.accentGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How NutriScan Works',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        FeatureCard(
          icon: Icons.camera_alt_rounded,
          title: 'Scan Product Labels',
          description: 'Use your phone\'s camera to capture ingredient lists on food packages',
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(height: 12),
        FeatureCard(
          icon: Icons.text_fields_rounded,
          title: 'Advanced OCR Processing',
          description: 'Our smart text recognition extracts and cleans ingredient information',
          color: AppTheme.accentGreen,
        ),
        const SizedBox(height: 12),
        FeatureCard(
          icon: Icons.analytics_rounded,
          title: 'Intelligent Analysis',
          description: 'Rule-based matching identifies harmful substances and their health impacts',
          color: AppTheme.moderateRisk,
        ),
        const SizedBox(height: 12),
        FeatureCard(
          icon: Icons.health_and_safety_rounded,
          title: 'Clear Results',
          description: 'Get instant feedback on product safety with detailed explanations',
          color: AppTheme.primaryGreen,
        ),
      ],
    );
  }

  Widget _buildImpactSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.moderateRisk.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: AppTheme.moderateRisk,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Our Impact on Food Safety',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildImpactStat(context, '20+', 'Harmful Ingredients', 'Tracked and identified'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImpactStat(context, '8', 'Categories', 'Different additive types'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'NutriScan helps consumers make informed decisions by providing instant access to information about food additives, preservatives, artificial colors, and other potentially harmful substances commonly found in processed foods.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactStat(BuildContext context, String number, String title, String subtitle) {
    return Column(
      children: [
        Text(
          number,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.mediumGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFuturePlansSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: AppTheme.accentGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Future Enhancements',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFuturePlan(context, '🤖', 'Machine Learning Integration', 
                'Advanced AI models for improved ingredient recognition and analysis'),
            _buildFuturePlan(context, '🌍', 'Global Database Expansion', 
                'Comprehensive international ingredient databases and regulations'),
            _buildFuturePlan(context, '👥', 'Community Features', 
                'User reviews, ratings, and crowdsourced ingredient information'),
            _buildFuturePlan(context, '📊', 'Personalized Health Insights', 
                'Customized recommendations based on dietary restrictions and health goals'),
          ],
        ),
      ),
    );
  }

  Widget _buildFuturePlan(BuildContext context, String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.group_rounded,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'About the Team',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'NutriScan is developed by a passionate team of health advocates, food scientists, and technology experts who believe in the power of information to transform public health.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Our diverse backgrounds in nutrition science, mobile app development, and user experience design enable us to create solutions that are both scientifically accurate and user-friendly.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
