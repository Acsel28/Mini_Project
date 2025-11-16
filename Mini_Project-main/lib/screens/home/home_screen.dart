import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../models/meal_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/meal_provider.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/progress_circle.dart';
import '../../widgets/quick_action_button.dart';
import '../../services/tts_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mealPlanProvider.notifier).loadTodaysMealPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final mealPlan = ref.watch(mealPlanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Diet App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () => _startVoiceInput(),
            tooltip: 'Voice Input',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshMealPlan(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              _buildGreetingSection(user),
              const SizedBox(height: 24),

              // Daily Progress Section
              _buildProgressSection(user, mealPlan),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Today's Meal Plan
              _buildTodaysMealPlan(mealPlan),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(User? user) {
    final greeting = _getGreeting();
    final userName = user?.name ?? 'there';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.gradientDecoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $userName! 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready for a healthy day?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(User? user, MealPlan? mealPlan) {
    final targetCalories = user?.targetCalories ?? 2000;
    final consumedCalories = mealPlan?.totalCalories ?? 0;
    final progress = consumedCalories / targetCalories;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ProgressCircle(
                  progress: progress.clamp(0.0, 1.0),
                  size: 100,
                  strokeWidth: 8,
                  backgroundColor: AppColors.background,
                  progressColor: AppColors.primary,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$consumedCalories',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'of $targetCalories',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    _buildMacroRow('Protein', mealPlan?.totalProtein ?? 0, AppColors.protein),
                    const SizedBox(height: 8),
                    _buildMacroRow('Carbs', mealPlan?.totalCarbs ?? 0, AppColors.carbs),
                    const SizedBox(height: 8),
                    _buildMacroRow('Fat', mealPlan?.totalFat ?? 0, AppColors.fat),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        Text('${value.toStringAsFixed(0)}g', 
             style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.restaurant,
                label: 'Plan Meals',
                color: AppColors.accent1,
                onPressed: () => _planMeals(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.kitchen,
                label: 'Use Ingredients',
                color: AppColors.accent2,
                onPressed: () => _navigateToTab(1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaysMealPlan(MealPlan? mealPlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Meals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => _regenerateMealPlan(),
              child: const Text('Regenerate'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (mealPlan == null) 
          _buildLoadingMealCards()
        else
          _buildMealCards(mealPlan),
      ],
    );
  }

  Widget _buildLoadingMealCards() {
    return Column(
      children: [
        _buildLoadingMealCard('Breakfast'),
        const SizedBox(height: 12),
        _buildLoadingMealCard('Lunch'),
        const SizedBox(height: 12),
        _buildLoadingMealCard('Dinner'),
      ],
    );
  }

  Widget _buildLoadingMealCard(String mealType) {
    return Container(
      height: 100,
      decoration: AppStyles.cardDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 8),
            Text('Loading $mealType...'),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCards(MealPlan mealPlan) {
    return Column(
      children: [
        if (mealPlan.breakfast != null) ...[
          MealCard(
            meal: mealPlan.breakfast!,
            mealType: 'Breakfast',
            color: AppColors.accent1,
          ),
          const SizedBox(height: 12),
        ],

        if (mealPlan.lunch != null) ...[
          MealCard(
            meal: mealPlan.lunch!,
            mealType: 'Lunch', 
            color: AppColors.accent2,
          ),
          const SizedBox(height: 12),
        ],

        if (mealPlan.dinner != null)
          MealCard(
            meal: mealPlan.dinner!,
            mealType: 'Dinner',
            color: AppColors.accent3,
          ),
      ],
    );
  }

  // Helper methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _refreshMealPlan() async {
    await ref.read(mealPlanProvider.notifier).loadTodaysMealPlan();
  }

  void _regenerateMealPlan() {
    ref.read(mealPlanProvider.notifier).regenerateMealPlan();
  }

  void _planMeals() {
    _regenerateMealPlan();
  }

  void _navigateToTab(int index) {
    // This would need to be implemented with navigation
  }

  void _startVoiceInput() {
    TTSService.speak('Voice input ready. What would you like to do?');
  }
}
