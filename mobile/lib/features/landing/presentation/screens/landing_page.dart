import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';

/// Landing Page - Pre-auth page with branding and features
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scrollController = ScrollController();
  bool _showElevation = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final shouldElevate = _scrollController.offset > 20;
      if (shouldElevate != _showElevation) {
        setState(() => _showElevation = shouldElevate);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaydeckTheme.background,
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Section
              SliverToBoxAdapter(child: _buildHeroSection(context)),
              
              // Features Section
              SliverToBoxAdapter(child: _buildFeaturesSection()),
              
              // How It Works Section
              SliverToBoxAdapter(child: _buildHowItWorksSection()),
              
              // About / Trust Section
              SliverToBoxAdapter(child: _buildAboutSection()),
              
              // CTA Section
              SliverToBoxAdapter(child: _buildCtaSection(context)),
              
              // Footer
              SliverToBoxAdapter(child: _buildFooter(context)),
            ],
          ),

          // Floating Nav Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildNavBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: _showElevation ? WaydeckTheme.surface : Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            border: _showElevation 
              ? Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)))
              : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              // Logo
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [WaydeckTheme.primary, WaydeckTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('✈️', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Waydeck',
                style: WaydeckTheme.heading2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Auth buttons
              TextButton(
                onPressed: () => context.push('/auth/signin'),
                child: const Text('Sign In'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => context.push('/auth/signup'),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 120, // Space for navbar
        left: 24,
        right: 24,
        bottom: 60,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            WaydeckTheme.primary.withValues(alpha: 0.05),
            WaydeckTheme.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: WaydeckTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'Your Ultimate Travel Companion',
                  style: WaydeckTheme.bodySmall.copyWith(
                    color: WaydeckTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Plan Smarter,\nTravel Better',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: WaydeckTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Organize flights, hotels, activities, and documents in one beautiful timeline. Never miss a detail on your journey again.',
              textAlign: TextAlign.center,
              style: WaydeckTheme.bodyLarge.copyWith(
                color: WaydeckTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.push('/auth/signup'),
                icon: const Icon(Icons.rocket_launch, size: 20),
                label: const Text('Start Planning Free'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          // Hero Image / Mockup Placeholder
          Container(
            height: 300,
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: WaydeckTheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: WaydeckTheme.primary.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
              border: Border.all(color: Colors.white, width: 4),
            ),
             child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Abstract Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          WaydeckTheme.primary.withValues(alpha: 0.1),
                          WaydeckTheme.secondary.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Mock UI Elements
                  Positioned(
                    top: 40,
                    left: 40,
                    right: 40,
                    bottom: 0,
                    child: Column(
                      children: [
                         _buildMockTripItem('09:00 AM', 'Flight to Tokyo', Icons.flight_takeoff, WaydeckTheme.transportColor),
                         const SizedBox(height: 16),
                         _buildMockTripItem('03:30 PM', 'Hotel Check-in', Icons.hotel, WaydeckTheme.stayColor),
                         const SizedBox(height: 16),
                         _buildMockTripItem('07:00 PM', 'Dinner at Shibuya', Icons.restaurant, WaydeckTheme.activityColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockTripItem(String time, String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(time, style: WaydeckTheme.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title, style: WaydeckTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      ('📅', 'Smart Timeline', 'View your entire trip in a beautiful day-by-day timeline.'),
      ('✈️', 'Transport', 'Track flights, trains, and buses with real-time details.'),
      ('🏨', 'Stays', 'Keep hotel and Airbnb reservations organized.'),
      ('💰', 'Budgeting', 'Track expenses and stay within your travel budget.'),
      ('📄', 'Documents', 'Access tickets and passports offline, anywhere.'),
      ('🌍', 'Global', 'Works for trips to any destination in the world.'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Text('Everything You Need', style: WaydeckTheme.heading2, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            'Powerful features to make trip planning effortless',
            style: WaydeckTheme.bodyLarge.copyWith(color: WaydeckTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: features.map((f) => SizedBox(
              width: 300,
              child: _buildFeatureCard(f.$1, f.$2, f.$3),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String emoji, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WaydeckTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WaydeckTheme.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 16),
          Text(title, style: WaydeckTheme.heading3),
          const SizedBox(height: 8),
          Text(
            description,
            style: WaydeckTheme.bodyMedium.copyWith(color: WaydeckTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      color: WaydeckTheme.surfaceVariant.withValues(alpha: 0.3),
      child: Column(
        children: [
          Text('How It Works', style: WaydeckTheme.heading2),
          const SizedBox(height: 48),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildStep(1, 'Create a Trip', 'Set your dates and destination.'),
                _buildStep(2, 'Add Details', 'Input flights, hotels, and activities.'),
                _buildStep(3, 'Stay Organized', 'Upload docs and track your budget.'),
                _buildStep(4, 'Enjoy', 'Access your itinerary properly on the go.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: WaydeckTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: WaydeckTheme.heading3),
                const SizedBox(height: 4),
                Text(description, style: WaydeckTheme.bodyLarge.copyWith(color: WaydeckTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          const Text('❤️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 24),
          Text('Built for Travelers', style: WaydeckTheme.heading2),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Waydeck is designed to take the stress out of travel planning, so you can focus on making memories.',
              textAlign: TextAlign.center,
              style: WaydeckTheme.bodyLarge.copyWith(color: WaydeckTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      color: WaydeckTheme.primary,
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'Ready to take off?',
            style: WaydeckTheme.heading2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Start planning your next adventure today.',
            style: WaydeckTheme.bodyLarge.copyWith(color: Colors.white.withValues(alpha: 0.9)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push('/auth/signup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: WaydeckTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Get Started Free'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: WaydeckTheme.surface,
      child: Center(
        child: Text(
          '© ${DateTime.now().year} Waydeck. All rights reserved.',
          style: WaydeckTheme.caption.copyWith(color: WaydeckTheme.textSecondary),
        ),
      ),
    );
  }
}
