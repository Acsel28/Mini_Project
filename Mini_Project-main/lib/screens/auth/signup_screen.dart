import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system.dart';
import '../../core/theme.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/ambient_background.dart';
import '../home/main_navigation_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();
  final allergiesController = TextEditingController();
  final targetCaloriesController = TextEditingController();

  String? selectedDisease;
  String? selectedDietPreference;
  String? selectedFitnessGoal;
  String? selectedActivityLevel;
  String? selectedMealType;
  String? selectedGender;

  bool loading = false;
  String? error;

  final List<Map<String, String>> diseases = [
    {'key': 'diabetes_type2', 'title': 'Diabetes Type 2'},
    {'key': 'hypertension', 'title': 'Hypertension'},
    {'key': 'pcos', 'title': 'PCOS'},
    {'key': 'knee_pain', 'title': 'Knee Pain'},
    {'key': 'lower_back_pain', 'title': 'Lower Back Pain'},
    {'key': 'thyroid', 'title': 'Thyroid'},
    {'key': 'obesity', 'title': 'Obesity'},
  ];

  final List<Map<String, String>> dietPreferences = [
    {'key': 'vegetarian', 'title': 'Vegetarian'},
    {'key': 'vegan', 'title': 'Vegan'},
    {'key': 'non_vegetarian', 'title': 'Non-Vegetarian'},
    {'key': 'pescatarian', 'title': 'Pescatarian'},
    {'key': 'keto', 'title': 'Keto'},
    {'key': 'paleo', 'title': 'Paleo'},
  ];

  final List<Map<String, String>> fitnessGoals = [
    {'key': 'weight_loss', 'title': 'Weight Loss'},
    {'key': 'muscle_gain', 'title': 'Muscle Gain'},
    {'key': 'maintenance', 'title': 'Maintenance'},
    {'key': 'strength', 'title': 'Build Strength'},
    {'key': 'endurance', 'title': 'Improve Endurance'},
    {'key': 'flexibility', 'title': 'Improve Flexibility'},
  ];

  final List<Map<String, String>> activityLevels = [
    {'key': 'sedentary', 'title': 'Sedentary (Little Exercise)'},
    {'key': 'lightly_active', 'title': 'Lightly Active (1-3 days/week)'},
    {'key': 'moderately_active', 'title': 'Moderately Active (3-5 days/week)'},
    {'key': 'very_active', 'title': 'Very Active (6-7 days/week)'},
  ];

  final List<Map<String, String>> mealTypes = [
    {'key': 'balanced', 'title': 'Balanced (All food groups)'},
    {'key': 'high_protein', 'title': 'High Protein'},
    {'key': 'low_carb', 'title': 'Low Carb'},
    {'key': 'low_fat', 'title': 'Low Fat'},
    {'key': 'mediterranean', 'title': 'Mediterranean'},
  ];

  final List<Map<String, String>> genders = [
    {'key': 'male', 'title': 'Male'},
    {'key': 'female', 'title': 'Female'},
    {'key': 'other', 'title': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in [heightController, weightController, ageController, targetCaloriesController]) {
      controller.addListener(_refreshInsights);
    }
  }

  void _refreshInsights() => setState(() {});

  @override
  void dispose() {
    for (final controller in [
      nameController,
      emailController,
      passwordController,
      heightController,
      weightController,
      ageController,
      allergiesController,
      targetCaloriesController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroHeader(context),
                    const SizedBox(height: AppSpacing.lg),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _SectionCard(
                            title: 'Account Essentials',
                            subtitle: 'Create secure login credentials to protect your health data.',
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: nameController,
                                  label: 'Full name',
                                  icon: Icons.badge_outlined,
                                  validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _buildTextField(
                                  controller: emailController,
                                  label: 'Email address',
                                  icon: Icons.alternate_email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Please enter your email';
                                    if (!value.contains('@')) return 'Enter a valid email';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _buildTextField(
                                  controller: passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Create a password';
                                    if (value.length < 6) return 'Use at least 6 characters';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SectionCard(
                            title: 'Body metrics',
                            subtitle: 'We tailor your plan based on science-backed calculations.',
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: ageController,
                                        label: 'Age',
                                        icon: Icons.cake_outlined,
                                        keyboardType: TextInputType.number,
                                        validator: (value) => value == null || value.isEmpty ? 'Age required' : null,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: _buildChipSelector(
                                        label: 'Gender',
                                        options: genders,
                                        selectedValue: selectedGender,
                                        onSelected: (value) => setState(() => selectedGender = value),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: heightController,
                                        label: 'Height (cm)',
                                        icon: Icons.height,
                                        keyboardType: TextInputType.number,
                                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: weightController,
                                        label: 'Weight (kg)',
                                        icon: Icons.monitor_weight,
                                        keyboardType: TextInputType.number,
                                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SectionCard(
                            title: 'Lifestyle goals',
                            subtitle: 'Tell us how active you are and where you want to go.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildChoiceWrap(
                                  label: 'Primary goal',
                                  options: fitnessGoals,
                                  selectedValue: selectedFitnessGoal,
                                  onSelected: (value) => setState(() => selectedFitnessGoal = value),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _buildChoiceWrap(
                                  label: 'Activity level',
                                  options: activityLevels,
                                  selectedValue: selectedActivityLevel,
                                  onSelected: (value) => setState(() => selectedActivityLevel = value),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _buildTextField(
                                  controller: targetCaloriesController,
                                  label: 'Daily target calories (optional)',
                                  icon: Icons.local_fire_department_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SectionCard(
                            title: 'Diet & health preferences',
                            subtitle: 'Personalize ingredients, meal styles, and medical context.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildChoiceWrap(
                                  label: 'Diet preference',
                                  options: dietPreferences,
                                  selectedValue: selectedDietPreference,
                                  onSelected: (value) => setState(() => selectedDietPreference = value),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _buildChoiceWrap(
                                  label: 'Preferred meal style',
                                  options: mealTypes,
                                  selectedValue: selectedMealType,
                                  onSelected: (value) => setState(() => selectedMealType = value),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _buildChoiceWrap(
                                  label: 'Health condition focus',
                                  options: diseases,
                                  selectedValue: selectedDisease,
                                  onSelected: (value) => setState(() => selectedDisease = value),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _buildTextField(
                                  controller: allergiesController,
                                  label: 'Allergies or restrictions',
                                  icon: Icons.health_and_safety_outlined,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildInsightsCard(),
                          const SizedBox(height: AppSpacing.md),
                          if (error != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius: AppRadius.md,
                              ),
                              child: Text(
                                error!,
                                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.md),
                          ElevatedButton.icon(
                            onPressed: loading ? null : _signup,
                            icon: loading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.rocket_launch_outlined),
                            label: Text(loading ? 'Creating your profile...' : 'Launch personalized plan'),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Design your AI health coach',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Answer a few quick questions so we can deliver meals, workouts, and biomarker insights that feel custom made.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    final border = OutlineInputBorder(
      borderRadius: AppRadius.md,
      borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2)),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        hintText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        prefixIcon: Icon(icon, color: AppColors.primaryDark),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.8), width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildChipSelector({
    required String label,
    required List<Map<String, String>> options,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final value = option['key']!;
            return ChoiceChip(
              label: Text(option['title'] ?? ''),
              selected: selectedValue == value,
              onSelected: (_) => onSelected(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChoiceWrap({
    required String label,
    required List<Map<String, String>> options,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final value = option['key']!;
            return ChoiceChip(
              label: Text(option['title'] ?? ''),
              selected: selectedValue == value,
              onSelected: (_) => onSelected(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInsightsCard() {
    final bmi = _calculateBmi();
    final suggestedCalories = _suggestedCalories();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instant insights',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InsightChip(label: 'BMI', value: bmi ?? '--'),
              const SizedBox(width: 12),
              _InsightChip(label: 'Target calories', value: suggestedCalories ?? '--'),
            ],
          ),
          const SizedBox(height: 12),
          const Text('We continually fine-tune these numbers once you start logging meals and workouts.'),
        ],
      ),
    );
  }

  String? _calculateBmi() {
    final weight = double.tryParse(weightController.text);
    final heightCm = double.tryParse(heightController.text);
    if (weight == null || heightCm == null || heightCm == 0) return null;
    final bmi = weight / ((heightCm / 100) * (heightCm / 100));
    return bmi.toStringAsFixed(1);
  }

  String? _suggestedCalories() {
    if (targetCaloriesController.text.isNotEmpty) return targetCaloriesController.text;
    final age = int.tryParse(ageController.text);
    final weight = double.tryParse(weightController.text);
    final height = double.tryParse(heightController.text);
    if (age == null || weight == null || height == null) return null;

    double bmr;
    if (selectedGender == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
    return bmr.round().toString();
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final missingSelection = _validateSelections();
    if (missingSelection != null) {
      setState(() => error = missingSelection);
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final result = await AuthService.register(
      emailController.text.trim(),
      passwordController.text.trim(),
      nameController.text.trim(),
      height: double.tryParse(heightController.text),
      weight: double.tryParse(weightController.text),
      age: int.tryParse(ageController.text),
      gender: selectedGender,
      disease: selectedDisease,
      dietPreference: selectedDietPreference,
      fitnessGoal: selectedFitnessGoal,
      activityLevel: selectedActivityLevel,
      allergies: allergiesController.text.trim().isEmpty ? null : allergiesController.text.trim(),
      mealType: selectedMealType,
      targetCalories: int.tryParse(targetCaloriesController.text.isEmpty ? _suggestedCalories() ?? '' : targetCaloriesController.text),
    );

    if (!result.success) {
      setState(() {
        loading = false;
        error = result.message;
      });
      return;
    }

    final profile = await UserService.fetchCurrentUser();

    if (profile == null) {
      setState(() {
        loading = false;
        error = 'Failed to load profile';
      });
      return;
    }

    await ref.read(userProvider.notifier).setUser(profile);

    setState(() => loading = false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  String? _validateSelections() {
    if (selectedGender == null) return 'Please choose a gender option';
    if (selectedDisease == null) return 'Select the health focus you want help managing';
    if (selectedDietPreference == null) return 'Tell us your diet preference';
    if (selectedMealType == null) return 'Pick at least one meal style you enjoy';
    if (selectedFitnessGoal == null) return 'Select a primary goal';
    if (selectedActivityLevel == null) return 'Select your activity level';
    return null;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: AppRadius.md,
          color: AppColors.surfaceAlt,
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
