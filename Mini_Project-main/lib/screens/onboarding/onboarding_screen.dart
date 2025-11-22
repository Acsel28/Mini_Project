import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/design_system.dart';
import '../../providers/user_provider.dart';
import '../../services/tts_service.dart';
import '../../services/disease_service.dart';
import '../../widgets/custom_button.dart';
import '../../services/user_service.dart';
import '../../widgets/reusable_components.dart';
import '../auth/signup_screen.dart';



// ⭐ NEW IMPORT FOR LOGIN
import '../auth/login_screen.dart';

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
  List<dynamic> _availableDiseases = [];
  final List<String> _selectedDiseaseIds = [];

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  Future<void> _loadDiseases() async {
    final d = await DiseaseService.getAllDiseases();
    if (d != null) {
      setState(() => _availableDiseases = d);
    }
  }

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
          SafeArea(child: _buildProgressIndicator()),
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
              color: AppColors.primary.withValues(alpha: 0.1),
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
              color: AppColors.textPrimary,
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

          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppStyles.cardDecoration,
            child: Row(
              children: [
                const Icon(Icons.accessibility, color: AppColors.primary),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Voice-First Mode\nEnhanced accessibility features',
                  ),
                ),
                Switch(
                  value: _accessibilityMode,
                  onChanged: (value) {
                    setState(() => _accessibilityMode = value);
                  },
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return AppColors.textSecondary;
                  }),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary.withValues(alpha: 0.35);
                    }
                    return AppColors.surfaceAlt;
                  }),
                  trackOutlineColor: WidgetStateProperty.all(
                    AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),

          // ⭐ LOGIN BUTTON ADDED HERE
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            child: Text(
              "Already have an account? Login",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 12),

GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  },
  child: Text(
    "New user? Create an account",
    style: TextStyle(
      color: AppColors.primary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us create personalized meal plans',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          _buildFilledField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildFilledField(
                  controller: _ageController,
                  label: 'Age',
                  hint: 'Your age',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: _dropdownDecoration('Gender', Icons.person_outline),
                  items: const [
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedGender = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildFilledField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  hint: 'E.g. 72',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilledField(
                  controller: _heightController,
                  label: 'Height (cm)',
                  hint: 'E.g. 168',
                  icon: Icons.height,
                  keyboardType: TextInputType.number,
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          _buildGoalOption(
              'weight_loss', 'Weight Loss', 'Lose weight safely', Icons.trending_down),
          _buildGoalOption(
              'weight_gain', 'Weight Gain', 'Gain healthy weight', Icons.trending_up),
          _buildGoalOption(
              'muscle_gain', 'Muscle Gain', 'Build lean muscle', Icons.fitness_center),
          _buildGoalOption(
              'maintenance', 'Maintenance', 'Maintain current weight', Icons.balance),
          _buildGoalOption(
              'healthy_eating', 'Healthy Eating', 'Focus on nutrition', Icons.favorite),
        ],
      ),
    );
  }

  Widget _buildGoalOption(
      String value, String title, String subtitle, IconData icon) {
    final isSelected = _selectedGoal == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
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
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          const Text('Health Conditions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _availableDiseases.isEmpty
              ? const Text('Loading conditions...')
              : Wrap(
                  spacing: 8,
                  children: [
                    for (final d in _availableDiseases)
                      FilterChip(
                        label: Text(d['title'] ?? d['keyname']),
                        selected: _selectedDiseaseIds.contains(d['id']),
                        onSelected: (v) {
                          setState(() {
                            if (v) _selectedDiseaseIds.add(d['id']);
                            else _selectedDiseaseIds.remove(d['id']);
                          });
                        },
                      ),
                  ],
                ),
          const SizedBox(height: 24),

          _buildDietOption('vegetarian', 'Vegetarian', '🥬'),
          _buildDietOption('vegan', 'Vegan', '🌱'),
          _buildDietOption('non_vegetarian', 'Non-Vegetarian', '🍗'),
          _buildDietOption('keto', 'Keto', '🥑'),

          const SizedBox(height: 32),

          const Text(
            'Language',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.md,
        side: BorderSide(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.4) : Colors.transparent,
        ),
      ),
      color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(emoji, style: const TextStyle(fontSize: 24)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        trailing: WellnessChoiceIndicator(selected: isSelected),
        onTap: () => setState(() => _selectedDietType = value),
      ),
    );
  }

  Widget _buildLanguageOption(String value, String title, String flag) {
    final isSelected = _selectedLanguage == value;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.md,
        side: BorderSide(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.4) : Colors.transparent,
        ),
      ),
      color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        trailing: WellnessChoiceIndicator(selected: isSelected),
        onTap: () => setState(() => _selectedLanguage = value),
      ),
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
    if (_currentPage == 1) {
      if (_nameController.text.isEmpty ||
          _ageController.text.isEmpty ||
          _weightController.text.isEmpty ||
          _heightController.text.isEmpty) {
        _showSnackBar('Please fill in all required fields');
        return false;
      }
    }
    return true;
  }
void _completeOnboarding() async {
  final userNotifier = ref.read(userProvider.notifier);

  // 1️⃣ Calculate calories
  final targetCalories = _calculateTargetCalories();

  // 2️⃣ Send profile to backend
  final success = await UserService.updateProfile(
    name: _nameController.text.trim(),
    age: int.tryParse(_ageController.text) ?? 25,
    gender: _selectedGender,
    heightCm: double.tryParse(_heightController.text) ?? 170.0,
    weightKg: double.tryParse(_weightController.text) ?? 65.0,
    language: _selectedLanguage,
    targetCalories: targetCalories,
    goal: _selectedGoal,
    dietPreference: _selectedDietType,
    accessibilityMode: _accessibilityMode,
    healthConditions: _selectedDiseaseIds,
    activityLevel: 'moderately_active',
  );

  if (!success) {
    _showSnackBar("Failed to save profile");
    return;
  }

  // 3️⃣ Fetch updated user
  final updatedUser = await UserService.fetchCurrentUser();
  if (updatedUser == null) {
    _showSnackBar("Something went wrong while loading your profile");
    return;
  }

  // 4️⃣ Save in provider
  await userNotifier.setUser(updatedUser);

    // 5️⃣ Navigate to home
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }

    // 6️⃣ Optional TTS
    if (_accessibilityMode) {
      TTSService.speak("Setup complete! Welcome to your AI Diet App");
    }
  }  int _calculateTargetCalories() {
    final age = int.tryParse(_ageController.text) ?? 25;
    final weight = double.tryParse(_weightController.text) ?? 65.0;
    final height = double.tryParse(_heightController.text) ?? 170.0;

    double bmr;
    if (_selectedGender == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    final tdee = bmr * 1.55;

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

  Widget _buildFilledField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      decoration: _fieldDecoration(label: label, hint: hint, icon: icon),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint ?? label,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryDark) : null,
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    final baseBorder = OutlineInputBorder(
      borderRadius: AppRadius.md,
      borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2)),
    );

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: AppColors.primaryDark),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
