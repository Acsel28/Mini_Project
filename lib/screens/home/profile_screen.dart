import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../../services/tts_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: user == null 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, user),
                const SizedBox(height: 24),

                // Health Stats
                _buildHealthStats(context, user),
                const SizedBox(height: 24),

                // Settings
                _buildSettings(context, ref),
                const SizedBox(height: 24),

                // Actions
                _buildActions(context, ref),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 32,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            '${user.age} years • ${user.gender}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Weight', '${user.weight.toInt()} kg'),
              _buildStatCard('Height', '${user.height.toInt()} cm'),
              _buildStatCard('BMI', user.bmi.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthStats(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildHealthRow('Goal', _getGoalText(user.goal)),
          _buildHealthRow('Diet Type', user.dietPreference),
          _buildHealthRow('Target Calories', '${user.targetCalories} cal/day'),
          _buildHealthRow('BMR', '${user.bmr.toInt()} cal/day'),
          _buildHealthRow('BMI Category', user.bmiCategory),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(context),
          ),

          ListTile(
            leading: const Icon(Icons.accessibility, color: AppColors.primary),
            title: const Text('Accessibility'),
            subtitle: const Text('Voice mode & high contrast'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showAccessibilityDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.help, color: AppColors.info),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showHelpDialog(context),
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () => _showSignOutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  String _getGoalText(String goal) {
    switch (goal) {
      case 'weight_loss': return 'Weight Loss';
      case 'weight_gain': return 'Weight Gain';
      case 'muscle_gain': return 'Muscle Gain';
      case 'maintenance': return 'Maintenance';
      default: return 'Healthy Eating';
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'english',
                groupValue: 'english',
                onChanged: (value) => Navigator.of(context).pop(),
              ),
            ),
            ListTile(
              title: const Text('हिन्दी (Hindi)'),
              leading: Radio<String>(
                value: 'hindi',
                groupValue: 'english',
                onChanged: (value) => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccessibilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accessibility Settings'),
        content: const Text('Accessibility settings will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'For help and support:\n\n'
          '• Email: support@aidietapp.com\n'
          '• Phone: +91-1234567890'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProvider.notifier).clearUser();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/onboarding');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
