import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../services/tts_service.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  // User data
  String _selectedGender = 'female';
  String _selectedGoal = 'weight_loss';
  String _selectedDietType = 'vegetarian';
  String _selectedLanguage = 'english';
  bool _accessibilityMode = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Progress Indicator
          SafeArea(child: _buildProgressIndicator()),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                _buildWelcomePage(),
                _buildBasicInfoPage(),
                _buildGoalsPage(),
                _buildPreferencesPage(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: List.generate(_totalPages, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentPage 
                  ? AppColors.primary 
                  : AppColors.background,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Welcome to AI Diet App',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Text(
            'Your personalized AI nutrition companion for a healthier lifestyle. Let\'s get to know you better!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Accessibility toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppStyles.cardDecoration,
            child: Row(
              children: [
                const Icon(Icons.accessibility, color: AppColors.primary),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text('Voice-First Mode\nEnhanced accessibility features'),
                ),
                Switch(
                  value: _accessibilityMode,
                  onChanged: (value) {
                    setState(() => _accessibilityMode = value);
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us create personalized meal plans',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    hintText: '25',
                    prefixIcon: Icon(Icons.cake),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedGender = value!);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: '65',
                    prefixIcon: Icon(Icons.monitor_weight),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    hintText: '170',
                    prefixIcon: Icon(Icons.height),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your goal?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          _buildGoalOption('weight_loss', 'Weight Loss', 
            'Lose weight safely and sustainably', Icons.trending_down),
          _buildGoalOption('weight_gain', 'Weight Gain', 
            'Gain healthy weight', Icons.trending_up),
          _buildGoalOption('muscle_gain', 'Muscle Gain', 
            'Build lean muscle mass', Icons.fitness_center),
          _buildGoalOption('maintenance', 'Maintenance', 
            'Maintain current weight', Icons.balance),
          _buildGoalOption('healthy_eating', 'Healthy Eating', 
            'Focus on nutrition and wellness', Icons.favorite),
        ],
      ),
    );
  }

  Widget _buildGoalOption(String value, String title, String subtitle, IconData icon) {
    final isSelected = _selectedGoal == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dietary Preferences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          _buildDietOption('vegetarian', 'Vegetarian', '🥬'),
          _buildDietOption('vegan', 'Vegan', '🌱'),
          _buildDietOption('non_vegetarian', 'Non-Vegetarian', '🍗'),
          _buildDietOption('keto', 'Keto', '🥑'),

          const SizedBox(height: 32),

          const Text(
            'Language',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildLanguageOption('english', 'English', '🇺🇸'),
          _buildLanguageOption('hindi', 'हिन्दी (Hindi)', '🇮🇳'),
        ],
      ),
    );
  }

  Widget _buildDietOption(String value, String title, String emoji) {
    final isSelected = _selectedDietType == value;

    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(title),
      trailing: Radio<String>(
        value: value,
        groupValue: _selectedDietType,
        onChanged: (val) => setState(() => _selectedDietType = val!),
        activeColor: AppColors.primary,
      ),
      onTap: () => setState(() => _selectedDietType = value),
    );
  }

  Widget _buildLanguageOption(String value, String title, String flag) {
    final isSelected = _selectedLanguage == value;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(title),
      trailing: Radio<String>(
        value: value,
        groupValue: _selectedLanguage,
        onChanged: (val) => setState(() => _selectedLanguage = val!),
        activeColor: AppColors.primary,
      ),
      onTap: () => setState(() => _selectedLanguage = value),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: CustomButton(
                text: 'Back',
                onPressed: () => _previousPage(),
                isOutlined: true,
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),

          Expanded(
            child: CustomButton(
              text: _currentPage == _totalPages - 1 ? 'Complete' : 'Next',
              onPressed: () => _nextPage(),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage == _totalPages - 1) {
      _completeOnboarding();
    } else {
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: AppConstants.shortAnimation,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: AppConstants.shortAnimation,
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 1: // Basic Info
        if (_nameController.text.isEmpty ||
            _ageController.text.isEmpty ||
            _weightController.text.isEmpty ||
            _heightController.text.isEmpty) {
          _showSnackBar('Please fill in all required fields');
          return false;
        }
        break;
      default:
        return true;
    }
    return true;
  }

  void _completeOnboarding() {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 25,
      weight: double.tryParse(_weightController.text) ?? 65.0,
      height: double.tryParse(_heightController.text) ?? 170.0,
      gender: _selectedGender,
      goal: _selectedGoal,
      targetCalories: _calculateTargetCalories(),
      dietPreference: _selectedDietType,
      language: _selectedLanguage,
      accessibilityMode: _accessibilityMode,
      healthConditions: [],
      activityLevel: 'moderately_active',
      createdAt: DateTime.now(),
    );

    ref.read(userProvider.notifier).setUser(user);
    Navigator.of(context).pushReplacementNamed('/home');

    if (_accessibilityMode) {
      TTSService.speak('Setup complete! Welcome to your AI Diet App');
    }
  }

  int _calculateTargetCalories() {
    final age = int.tryParse(_ageController.text) ?? 25;
    final weight = double.tryParse(_weightController.text) ?? 65.0;
    final height = double.tryParse(_heightController.text) ?? 170.0;

    // Simple BMR calculation
    double bmr;
    if (_selectedGender == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    final tdee = bmr * 1.55; // Moderate activity

    switch (_selectedGoal) {
      case 'weight_loss':
        return (tdee - 500).round();
      case 'weight_gain':
        return (tdee + 500).round();
      default:
        return tdee.round();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
