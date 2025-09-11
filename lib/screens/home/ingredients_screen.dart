import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/meal_provider.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/custom_button.dart';
import '../../services/tts_service.dart';

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});

  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _selectedIngredients = [];

  final List<String> _commonIngredients = [
    'Rice', 'Wheat', 'Dal', 'Onion', 'Tomato', 'Potato',
    'Paneer', 'Milk', 'Eggs', 'Oil', 'Salt', 'Garlic'
  ];

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeSuggestions = ref.watch(recipeSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Ingredients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () => _startVoiceInput(),
            tooltip: 'Voice input',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            _buildInputSection(),
            const SizedBox(height: 24),

            // Selected Ingredients
            if (_selectedIngredients.isNotEmpty) ...[
              _buildSelectedIngredients(),
              const SizedBox(height: 24),
            ],

            // Quick Selection
            _buildQuickSelection(),
            const SizedBox(height: 24),

            // Generate Recipes Button
            if (_selectedIngredients.isNotEmpty) ...[
              _buildGenerateButton(),
              const SizedBox(height: 24),
            ],

            // Recipe Suggestions
            _buildRecipeSuggestions(recipeSuggestions),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What ingredients do you have?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ingredientController,
                  decoration: InputDecoration(
                    hintText: 'e.g., rice, dal, onion',
                    prefixIcon: const Icon(Icons.kitchen),
                    suffixIcon: _ingredientController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addIngredient,
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _addIngredient(),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedIngredients() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Ingredients (${_selectedIngredients.length})',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedIngredients.map((ingredient) {
              return Chip(
                label: Text(ingredient),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeIngredient(ingredient),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                deleteIconColor: AppColors.primary,
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          TextButton.icon(
            onPressed: _clearAllIngredients,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear All'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Selection',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppStyles.cardDecoration,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonIngredients.map((ingredient) {
              final isSelected = _selectedIngredients.contains(ingredient);
              return FilterChip(
                label: Text(ingredient),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    _addIngredientFromList(ingredient);
                  } else {
                    _removeIngredient(ingredient);
                  }
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return CustomButton(
      text: 'Generate Recipe Ideas',
      onPressed: _generateRecipes,
      icon: Icons.auto_fix_high,
      isLoading: ref.watch(recipeSuggestionsProvider).isLoading,
    );
  }

  Widget _buildRecipeSuggestions(AsyncValue<List> recipeSuggestions) {
    return recipeSuggestions.when(
      data: (recipes) {
        if (recipes.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipe Suggestions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...recipes.map((recipe) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MealCard(
                meal: recipe,
                mealType: 'Recipe',
                color: AppColors.secondary,
              ),
            )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Error loading recipes: $error'),
      ),
    );
  }

  // Helper methods
  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty && !_selectedIngredients.contains(ingredient)) {
      setState(() {
        _selectedIngredients.add(ingredient);
        _ingredientController.clear();
      });
      TTSService.speak('$ingredient added');
    }
  }

  void _addIngredientFromList(String ingredient) {
    if (!_selectedIngredients.contains(ingredient)) {
      setState(() {
        _selectedIngredients.add(ingredient);
      });
      TTSService.speak('$ingredient added');
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _selectedIngredients.remove(ingredient);
    });
    TTSService.speak('$ingredient removed');
  }

  void _clearAllIngredients() {
    setState(() {
      _selectedIngredients.clear();
    });
    TTSService.speak('All ingredients cleared');
  }

  void _generateRecipes() {
    if (_selectedIngredients.isNotEmpty) {
      ref.read(recipeSuggestionsProvider.notifier).getRecipesByIngredients(_selectedIngredients);
      TTSService.speak('Generating recipe suggestions');
    }
  }

  void _startVoiceInput() {
    TTSService.speak('Say your ingredients');
  }
}
