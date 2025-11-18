import 'package:flutter/material.dart';
import '../../services/disease_service.dart';

class HealthRecommendationsScreen extends StatefulWidget {
  final String diseaseKey;
  final String diseaseName;

  const HealthRecommendationsScreen({
    Key? key,
    required this.diseaseKey,
    required this.diseaseName,
  }) : super(key: key);

  @override
  State<HealthRecommendationsScreen> createState() =>
      _HealthRecommendationsScreenState();
}

class _HealthRecommendationsScreenState extends State<HealthRecommendationsScreen> {
  late Future<Map<String, dynamic>?> _profileFuture;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _profileFuture = DiseaseService.getFullDiseaseProfile(widget.diseaseKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diseaseName),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading recommendations'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _profileFuture = DiseaseService.getFullDiseaseProfile(widget.diseaseKey);
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = snapshot.data!;
          final diet = profile['diet'] as Map<String, dynamic>?;
          final exercise = profile['exercise'] as Map<String, dynamic>?;
          final lifestyle = profile['lifestyle'] as Map<String, dynamic>?;

          return Column(
            children: [
              // Tab buttons
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    _buildTabButton(0, 'Diet', Icons.restaurant),
                    const SizedBox(width: 12),
                    _buildTabButton(1, 'Exercises', Icons.fitness_center),
                    const SizedBox(width: 12),
                    _buildTabButton(2, 'Lifestyle', Icons.health_and_safety),
                  ],
                ),
              ),
              // Tab content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildTabContent(_selectedTabIndex, diet, exercise, lifestyle),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    int tabIndex,
    Map<String, dynamic>? diet,
    Map<String, dynamic>? exercise,
    Map<String, dynamic>? lifestyle,
  ) {
    if (tabIndex == 0) {
      return _buildDietTab(diet);
    } else if (tabIndex == 1) {
      return _buildExerciseTab(exercise);
    } else {
      return _buildLifestyleTab(lifestyle);
    }
  }

  Widget _buildDietTab(Map<String, dynamic>? diet) {
    if (diet == null) {
      return const Center(child: Text('No diet information available'));
    }

    final recommendedFoods = (diet['recommendedFoods'] as List<dynamic>?) ?? [];
    final avoidFoods = (diet['avoidFoods'] as List<dynamic>?) ?? [];
    final summary = diet['summary'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.isNotEmpty) ...[
          _buildSectionHeader('Summary'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(summary, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(height: 20),
        ],
        if (recommendedFoods.isNotEmpty) ...[
          _buildSectionHeader('Recommended Foods'),
          _buildFoodList(recommendedFoods, Colors.green),
          const SizedBox(height: 20),
        ],
        if (avoidFoods.isNotEmpty) ...[
          _buildSectionHeader('Foods to Avoid'),
          _buildFoodList(avoidFoods, Colors.red),
        ],
      ],
    );
  }

  Widget _buildExerciseTab(Map<String, dynamic>? exercise) {
    if (exercise == null) {
      return const Center(child: Text('No exercise information available'));
    }

    final recommended = (exercise['recommendedExercises'] as List<dynamic>?) ?? [];
    final avoid = (exercise['exercisesToAvoid'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recommended.isNotEmpty) ...[
          _buildSectionHeader('Recommended Exercises'),
          ..._buildExerciseList(recommended, Colors.green),
          const SizedBox(height: 20),
        ],
        if (avoid.isNotEmpty) ...[
          _buildSectionHeader('Exercises to Avoid'),
          ..._buildExerciseList(avoid, Colors.red),
        ],
      ],
    );
  }

  Widget _buildLifestyleTab(Map<String, dynamic>? lifestyle) {
    if (lifestyle == null) {
      return const Center(child: Text('No lifestyle information available'));
    }

    final tips = (lifestyle['tips'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tips.isNotEmpty) ...[
          _buildSectionHeader('Lifestyle Tips'),
          Column(
            children: tips
                .map((tip) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.purple, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(tip.toString(), style: Theme.of(context).textTheme.bodySmall),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFoodList(List<dynamic> foods, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: foods
          .map((food) => Chip(
                label: Text(food.toString()),
                backgroundColor: color.withOpacity(0.2),
                labelStyle: TextStyle(color: color),
                side: BorderSide(color: color.withOpacity(0.5)),
              ))
          .toList(),
    );
  }

  List<Widget> _buildExerciseList(List<dynamic> exercises, Color color) {
    return exercises
        .map((exercise) {
          final Map<String, dynamic> ex = exercise is Map ? exercise as Map<String, dynamic> : {};
          final name = ex['name'] as String? ?? 'Unknown';
          final difficulty = ex['difficulty'] as String? ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: color.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
              color: color.withOpacity(0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (difficulty.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      difficulty,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
          );
        })
        .toList();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
