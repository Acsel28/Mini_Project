import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../providers/user_provider.dart';
import '../home/main_navigation_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
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

  // List of diseases from database
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
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    allergiesController.dispose();
    targetCaloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Complete Your Health Profile",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Basic Information
            _buildSectionTitle("Basic Information"),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),

            // Physical Information
            _buildSectionTitle("Physical Information"),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Select Gender"),
              value: selectedGender,
              onChanged: (value) => setState(() => selectedGender = value),
              items: genders.map((gender) {
                return DropdownMenuItem<String>(
                  value: gender['key'],
                  child: Text(gender['title'] ?? ''),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: heightController,
              decoration: const InputDecoration(labelText: "Height (cm)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: "Weight (kg)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Health Conditions
            _buildSectionTitle("Health Information"),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Select Health Condition"),
              value: selectedDisease,
              onChanged: (value) => setState(() => selectedDisease = value),
              items: diseases.map((disease) {
                return DropdownMenuItem<String>(
                  value: disease['key'],
                  child: Text(disease['title'] ?? ''),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: allergiesController,
              decoration: const InputDecoration(
                labelText: "Allergies / Dietary Restrictions",
                hintText: "e.g., Peanuts, Dairy, Gluten",
              ),
            ),
            const SizedBox(height: 20),

            // Diet & Nutrition
            _buildSectionTitle("Diet & Nutrition Preferences"),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Select Diet Preference"),
              value: selectedDietPreference,
              onChanged: (value) => setState(() => selectedDietPreference = value),
              items: dietPreferences.map((diet) {
                return DropdownMenuItem<String>(
                  value: diet['key'],
                  child: Text(diet['title'] ?? ''),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Select Preferred Meal Type"),
              value: selectedMealType,
              onChanged: (value) => setState(() => selectedMealType = value),
              items: mealTypes.map((meal) {
                return DropdownMenuItem<String>(
                  value: meal['key'],
                  child: Text(meal['title'] ?? ''),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: targetCaloriesController,
              decoration: const InputDecoration(
                labelText: "Daily Target Calories (optional)",
                hintText: "e.g., 2000",
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Fitness Goals & Activity
            _buildSectionTitle("Fitness Goals & Activity Level"),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Select Fitness Goal"),
              value: selectedFitnessGoal,
              onChanged: (value) => setState(() => selectedFitnessGoal = value),
              items: fitnessGoals.map((goal) {
                return DropdownMenuItem<String>(
                  value: goal['key'],
                  child: Text(goal['title'] ?? ''),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Select Activity Level"),
              value: selectedActivityLevel,
              onChanged: (value) => setState(() => selectedActivityLevel = value),
              items: activityLevels.map((activity) {
                return DropdownMenuItem<String>(
                  value: activity['key'],
                  child: Text(activity['title'] ?? ''),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _signup,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Account"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Future<void> _signup() async {
    if (!_validateInputs()) return;

    setState(() {
      loading = true;
      error = null;
    });

    final result = await AuthService.register(
      emailController.text.trim(),
      passwordController.text.trim(),
      nameController.text.trim(),
      height: heightController.text.isNotEmpty ? double.tryParse(heightController.text) : null,
      weight: weightController.text.isNotEmpty ? double.tryParse(weightController.text) : null,
      age: ageController.text.isNotEmpty ? int.tryParse(ageController.text) : null,
      gender: selectedGender,
      disease: selectedDisease,
      dietPreference: selectedDietPreference,
      fitnessGoal: selectedFitnessGoal,
      activityLevel: selectedActivityLevel,
      allergies: allergiesController.text.trim().isEmpty ? null : allergiesController.text.trim(),
      mealType: selectedMealType,
      targetCalories: targetCaloriesController.text.isNotEmpty ? int.tryParse(targetCaloriesController.text) : null,
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
        error = "Failed to load profile";
      });
      return;
    }

    await ref.read(userProvider.notifier).setUser(profile);

    setState(() => loading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  bool _validateInputs() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      setState(() => error = "Please fill all required fields");
      return false;
    }

    if (selectedDisease == null ||
        selectedDietPreference == null ||
        selectedFitnessGoal == null ||
        selectedActivityLevel == null ||
        selectedGender == null) {
      setState(() => error = "Please select all options");
      return false;
    }

    if (heightController.text.isEmpty || weightController.text.isEmpty) {
      setState(() => error = "Height and weight are required");
      return false;
    }

    if (ageController.text.isEmpty) {
      setState(() => error = "Age is required");
      return false;
    }

    return true;
  }
}
