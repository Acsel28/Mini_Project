import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/design_system.dart';
import '../../models/meal_model.dart';
import '../../models/recipe_suggestions_model.dart';
import '../../providers/meal_provider.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/wellness_scaffold.dart';
import '../../services/tts_service.dart';
import '../../services/voice_assistant_service.dart';

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

    return WellnessScaffold(
      title: 'Pantry assistant',
      subtitle: 'Turn ingredients into chef-crafted meals',
      actions: [
        IconButton(
          icon: const Icon(Icons.mic_none_rounded),
          tooltip: 'Voice input',
          onPressed: _startVoiceInput,
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputSection(),
            const SizedBox(height: 24),
            if (_selectedIngredients.isNotEmpty) ...[
              _buildSelectedIngredients(),
              const SizedBox(height: 24),
            ],
            _buildQuickSelection(),
            const SizedBox(height: 24),
            if (_selectedIngredients.isNotEmpty) ...[
              _buildGenerateButton(),
              const SizedBox(height: 24),
            ],
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
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Add ingredients',
                    hintText: 'e.g., rice, dal, onion',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.kitchen, color: AppColors.primaryDark),
                    suffixIcon: _ingredientController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.add, color: AppColors.primaryDark),
                            onPressed: _addIngredient,
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
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
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
          decoration: AppStyles.cardDecoration.copyWith(
            borderRadius: AppRadius.lg,
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 12,
            children: _commonIngredients.map((ingredient) {
              final isSelected = _selectedIngredients.contains(ingredient);
              return FilterChip(
                label: Text(
                  ingredient,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                  ),
                ),
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                selected: isSelected,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceAlt.withValues(alpha: 0.9),
                ),
                backgroundColor: AppColors.surfaceAlt.withValues(alpha: 0.8),
                selectedColor: AppColors.primary.withValues(alpha: 0.18),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                onSelected: (selected) {
                  if (selected) {
                    _addIngredientFromList(ingredient);
                  } else {
                    _removeIngredient(ingredient);
                  }
                },
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

  Widget _buildRecipeSuggestions(AsyncValue<RecipeSuggestionsResult> recipeSuggestions) {
    return recipeSuggestions.when(
      data: (result) {
        if (result.isEmpty) return const SizedBox();

        final showPantryRail = result.isAiChef && result.pantryMatches.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultMetadata(result),
            const SizedBox(height: 20),
            if (result.recipes.isNotEmpty) ...[
              const Text(
                'Recipe Suggestions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...result.recipes.map((recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: MealCard(
                      meal: recipe,
                      mealType: 'Recipe',
                      color: AppColors.secondary,
                    ),
                  )),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: AppStyles.cardDecoration,
                child: const Text(
                  'No exact recipe matches yet — try adding one more ingredient or tapping quick selections.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
            if (showPantryRail) ...[
              const SizedBox(height: 24),
              _buildPantryMatches(result.pantryMatches),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Error loading recipes: $error'),
      ),
    );
  }

  Widget _buildResultMetadata(RecipeSuggestionsResult result) {
    final isAi = result.isAiChef;
    final borderColor = isAi ? AppColors.primary : AppColors.secondary;
    final icon = isAi ? Icons.auto_awesome : Icons.inventory_2_rounded;
    final label = isAi ? 'AI Chef suggestions' : 'Pantry smart matches';
    final subtitle = isAi
        ? 'Crafted with ${result.ingredients.length} pantry items'
        : 'Showing best matches from your stored meals';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppStyles.cardDecoration.copyWith(
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: borderColor),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          if (result.topIngredients.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.topIngredients
                  .map((ingredient) => Chip(
                        avatar: const Icon(Icons.check, size: 16),
                        label: Text(ingredient),
                        backgroundColor: AppColors.surfaceAlt,
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Source: ${isAi ? 'Groq AI pantry chef' : 'Local pantry knowledge base'}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPantryMatches(List<Meal> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.kitchen_outlined, color: AppColors.primaryDark, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Pantry backups',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...meals.map((meal) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: MealCard(
                meal: meal,
                mealType: 'Pantry match',
                color: AppColors.primary,
              ),
            )),
      ],
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

  Future<void> _startVoiceInput() async {
    final granted = await VoiceAssistantService.ensureMicPermission();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable microphone access to dictate ingredients.')),
      );
      return;
    }

    await TTSService.speak('Ready for your ingredients');
    final transcript = await VoiceAssistantService.captureSingleCommand(
      listenFor: const Duration(seconds: 6),
    );

    if (!mounted) return;

    if (transcript == null || transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sorry, I did not catch that.')),
      );
      return;
    }

    final parts = transcript.split(RegExp('[,]|and')).map((p) => p.trim()).where((p) => p.isNotEmpty);
    setState(() {
      for (final ingredient in parts) {
        if (!_selectedIngredients.contains(ingredient)) {
          _selectedIngredients.add(ingredient);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added: $transcript')),
    );
  }
}
