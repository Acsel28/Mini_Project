import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../../services/profile_service.dart';

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
      body: user != null
          // ✅ OLD BEHAVIOUR: when local user is available, use full UI
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  _buildProfileHeaderLocal(context, user),
                  const SizedBox(height: 24),
                  _buildHealthStatsLocal(context, user),
                  const SizedBox(height: 24),
                  _buildSettings(context),
                  const SizedBox(height: 24),
                  _buildActions(context, ref),
                ],
              ),
            )
          // ✅ NEW: when local user is null, load from backend instead of spinning forever
          : FutureBuilder<Map<String, dynamic>>(
              future: ProfileService.getMe(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Could not load profile.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No profile data found.'),
                  );
                }

                final data = snapshot.data!;
                final userMap = (data['user'] as Map?) ?? {};
                final profile = (data['profile'] as Map?) ?? {};

                final name =
                    (userMap['name'] ?? userMap['email'] ?? 'User').toString();
                final age = profile['age']?.toString() ?? '--';
                final gender = profile['gender']?.toString() ?? '--';
                final height = profile['height_cm']?.toString() ?? '--';
                final weight = profile['weight_kg']?.toString() ?? '--';
                final dietType = profile['diet_type']?.toString() ?? 'Not set';
                final targetCalories =
                    profile['target_calories']?.toString() ?? '--';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      _buildProfileHeaderRemote(
                        context,
                        name: name,
                        age: age,
                        gender: gender,
                        height: height,
                        weight: weight,
                      ),
                      const SizedBox(height: 24),
                      _buildHealthStatsRemote(
                        context,
                        dietType: dietType,
                        targetCalories: targetCalories,
                      ),
                      const SizedBox(height: 24),
                      _buildSettings(context),
                      const SizedBox(height: 24),
                      _buildActions(context, ref),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // --------------------
  // LOCAL USER VERSION (uses your existing User model)
  // --------------------

  Widget _buildProfileHeaderLocal(BuildContext context, dynamic user) {
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

  Widget _buildHealthStatsLocal(BuildContext context, dynamic user) {
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

  // --------------------
  // REMOTE-ONLY VERSION (when userProvider is null)
  // --------------------

  Widget _buildProfileHeaderRemote(
    BuildContext context, {
    required String name,
    required String age,
    required String gender,
    required String height,
    required String weight,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 32,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$age years • $gender',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Weight', '$weight kg'),
              _buildStatCard('Height', '$height cm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatsRemote(
    BuildContext context, {
    required String dietType,
    required String targetCalories,
  }) {
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
          _buildHealthRow('Diet Type', dietType),
          _buildHealthRow('Target Calories', '$targetCalories cal/day'),
        ],
      ),
    );
  }

  // --------------------
  // Shared UI helpers
  // --------------------

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

  Widget _buildSettings(BuildContext context) {
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
            title: const Text(
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
      case 'weight_loss':
        return 'Weight Loss';
      case 'weight_gain':
        return 'Weight Gain';
      case 'muscle_gain':
        return 'Muscle Gain';
      case 'maintenance':
        return 'Maintenance';
      default:
        return 'Healthy Eating';
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
        content:
            const Text('Accessibility settings will be implemented soon.'),
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
          '• Phone: +91-1234567890',
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
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
