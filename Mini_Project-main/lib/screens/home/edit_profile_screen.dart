import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../services/user_service.dart';
import '../../services/disease_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/reusable_components.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _targetCaloriesController;

  String _selectedGender = 'female';
  String _selectedGoal = 'weight_loss';
  String _selectedDietType = 'vegetarian';
  String _selectedLanguage = 'english';
  String _selectedActivityLevel = 'moderately_active';
  bool _accessibilityMode = false;
  List<String> _selectedHealthConditions = [];
  List<dynamic> _availableDiseases = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController = TextEditingController(text: user?.age.toString() ?? '');
    _weightController = TextEditingController(text: user?.weight.toString() ?? '');
    _heightController = TextEditingController(text: user?.height.toString() ?? '');
    _targetCaloriesController = TextEditingController(text: user?.targetCalories.toString() ?? '2000');
    
    _selectedGender = user?.gender ?? 'female';
    _selectedGoal = user?.goal ?? 'weight_loss';
    _selectedDietType = user?.dietPreference ?? 'vegetarian';
    _selectedLanguage = user?.language ?? 'english';
    _selectedActivityLevel = user?.activityLevel ?? 'moderately_active';
    _accessibilityMode = user?.accessibilityMode ?? false;
    _selectedHealthConditions = List.from(user?.healthConditions ?? []);
    
    _loadDiseases();
  }

  Future<void> _loadDiseases() async {
    setState(() => _isLoading = true);
    final diseases = await DiseaseService.getAllDiseases();
    if (diseases != null) {
      setState(() {
        _availableDiseases = diseases;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _targetCaloriesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Validate inputs
    if (_nameController.text.isEmpty) {
      _showSnackBar('Please enter your name');
      return;
    }
    if (_ageController.text.isEmpty) {
      _showSnackBar('Please enter your age');
      return;
    }
    if (_weightController.text.isEmpty) {
      _showSnackBar('Please enter your weight');
      return;
    }
    if (_heightController.text.isEmpty) {
      _showSnackBar('Please enter your height');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final success = await UserService.updateProfile(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 25,
        gender: _selectedGender,
        heightCm: double.tryParse(_heightController.text) ?? 170.0,
        weightKg: double.tryParse(_weightController.text) ?? 65.0,
        language: _selectedLanguage,
        targetCalories: int.tryParse(_targetCaloriesController.text) ?? 2000,
        goal: _selectedGoal,
        dietPreference: _selectedDietType,
        accessibilityMode: _accessibilityMode,
        healthConditions: _selectedHealthConditions,
        activityLevel: _selectedActivityLevel,
      );

      if (!mounted) return;

      if (success) {
        // Refresh user data
        final updatedUser = await UserService.fetchCurrentUser();
        if (updatedUser != null) {
          ref.read(userProvider.notifier).setUser(updatedUser);
        }
        
        _showSnackBar('Profile updated successfully', isSuccess: true);
        Navigator.of(context).pop();
      } else {
        _showSnackBar('Failed to update profile');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  _buildSectionTitle('Basic Information'),
                  _buildTextField('Full Name', _nameController),
                  _buildTextField('Age', _ageController, keyboardType: TextInputType.number),
                  _buildTextField('Weight (kg)', _weightController, keyboardType: TextInputType.number),
                  _buildTextField('Height (cm)', _heightController, keyboardType: TextInputType.number),
                  _buildTextField('Target Calories', _targetCaloriesController, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),

                  // Gender Selection
                  _buildSectionTitle('Gender'),
                  _buildRadioGroup(
                    items: [
                      ('male', 'Male', '👨'),
                      ('female', 'Female', '👩'),
                      ('other', 'Other', '🧑'),
                    ],
                    selectedValue: _selectedGender,
                    onChanged: (value) => setState(() => _selectedGender = value),
                  ),
                  const SizedBox(height: 16),

                  // Health & Fitness Goals
                  _buildSectionTitle('Fitness Goal'),
                  _buildRadioGroup(
                    items: [
                      ('weight_loss', 'Weight Loss', '⬇️'),
                      ('weight_gain', 'Weight Gain', '⬆️'),
                      ('muscle_gain', 'Muscle Gain', '💪'),
                      ('maintenance', 'Maintenance', '➡️'),
                    ],
                    selectedValue: _selectedGoal,
                    onChanged: (value) => setState(() => _selectedGoal = value),
                  ),
                  const SizedBox(height: 16),

                  // Activity Level
                  _buildSectionTitle('Activity Level'),
                  _buildRadioGroup(
                    items: [
                      ('sedentary', 'Sedentary (Little exercise)', '🛋️'),
                      ('lightly_active', 'Lightly Active (1-3 days/week)', '🚶'),
                      ('moderately_active', 'Moderately Active (3-5 days/week)', '🏃'),
                      ('very_active', 'Very Active (6-7 days/week)', '⚡'),
                    ],
                    selectedValue: _selectedActivityLevel,
                    onChanged: (value) => setState(() => _selectedActivityLevel = value),
                  ),
                  const SizedBox(height: 16),

                  // Dietary Preferences
                  _buildSectionTitle('Dietary Preference'),
                  _buildRadioGroup(
                    items: [
                      ('vegetarian', 'Vegetarian', '🥬'),
                      ('vegan', 'Vegan', '🌱'),
                      ('non_vegetarian', 'Non-Vegetarian', '🍗'),
                      ('keto', 'Keto', '🥑'),
                    ],
                    selectedValue: _selectedDietType,
                    onChanged: (value) => setState(() => _selectedDietType = value),
                  ),
                  const SizedBox(height: 16),

                  // Health Conditions
                  _buildSectionTitle('Health Conditions'),
                  if (_availableDiseases.isEmpty)
                    const Text('Loading conditions...')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final disease in _availableDiseases)
                          FilterChip(
                            label: Text(disease['title'] ?? disease['keyname'] ?? 'Unknown'),
                            selected: _selectedHealthConditions.contains(disease['id']),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedHealthConditions.add(disease['id']);
                                } else {
                                  _selectedHealthConditions.remove(disease['id']);
                                }
                              });
                            },
                            backgroundColor: Colors.grey[100],
                            selectedColor: AppColors.primary.withValues(alpha: 0.3),
                            checkmarkColor: AppColors.primary,
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Language Selection
                  _buildSectionTitle('Language'),
                  _buildRadioGroup(
                    items: [
                      ('english', 'English', '🇺🇸'),
                      ('hindi', 'हिन्दी (Hindi)', '🇮🇳'),
                    ],
                    selectedValue: _selectedLanguage,
                    onChanged: (value) => setState(() => _selectedLanguage = value),
                  ),
                  const SizedBox(height: 16),

                  // Accessibility Mode
                  _buildSectionTitle('Accessibility'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.accessibility, color: AppColors.primary),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Voice Mode',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Enhanced voice & high contrast',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
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
                                return AppColors.primary.withValues(alpha: 0.45);
                              }
                              return AppColors.surfaceAlt;
                            }),
                            trackOutlineColor: WidgetStateProperty.all(
                              AppColors.primary.withValues(alpha: 0.25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRadioGroup({
    required List<(String, String, String)> items,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Column(
      children: [
        for (final (value, label, emoji) in items)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Text(emoji, style: const TextStyle(fontSize: 24)),
              title: Text(label),
              trailing: WellnessChoiceIndicator(
                selected: selectedValue == value,
                color: AppColors.primary,
              ),
              onTap: () => onChanged(value),
            ),
          ),
      ],
    );
  }
}
