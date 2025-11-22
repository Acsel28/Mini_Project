import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/design_system.dart';
import '../../core/theme.dart';
import '../../models/ai_content_models.dart';
import '../../models/meal_model.dart';
import '../../models/user_model.dart';
import '../../providers/meal_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/ai_content_provider.dart';
import '../../services/voice_assistant_service.dart';
import '../../widgets/ambient_background.dart';
import '../../widgets/health_checklist_widget.dart';
import '../../widgets/hydration_sleep_widget.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/progress_circle.dart';
import '../../widgets/quick_action_button.dart';
import 'coach_chat_screen.dart';
import 'disease_exercises_screen.dart';
import 'disease_mealplan_screen.dart';
import 'ingredients_screen.dart';
import 'nutrition_analytics_screen.dart';
import 'progress_screen.dart';
import 'meal_selection_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _weekdays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  int _selectedDayIndex = DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mealPlanProvider.notifier).loadTodaysMealPlan();
    });
  }

  Color _suggestionColor(String category) {
    switch (category.toLowerCase()) {
      case 'chef':
        return AppColors.accent1;
      case 'mindfulness':
        return AppColors.accent4;
      case 'recovery':
        return AppColors.secondary;
      case 'insight':
      default:
        return AppColors.primary;
    }
  }

  IconData _suggestionIcon(String category) {
    switch (category.toLowerCase()) {
      case 'chef':
        return Icons.restaurant_menu;
      case 'mindfulness':
        return Icons.self_improvement;
      case 'recovery':
        return Icons.bloodtype;
      case 'insight':
      default:
        return Icons.lightbulb_outline;
    }
  }

  IconData _insightIcon(String category) {
    switch (category.toLowerCase()) {
      case 'movement':
        return Icons.directions_run;
      case 'hydration':
        return Icons.water_drop_outlined;
      case 'mindset':
        return Icons.self_improvement;
      case 'biomarker':
      default:
        return Icons.monitor_heart;
    }
  }

  Color _insightColor(String category) {
    switch (category.toLowerCase()) {
      case 'movement':
        return AppColors.accent2;
      case 'hydration':
        return AppColors.accent4;
      case 'mindset':
        return AppColors.primary;
      case 'biomarker':
      default:
        return AppColors.info;
    }
  }

  Widget _buildStatusCard({
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final mealPlan = ref.watch(mealPlanProvider);
    final smartSuggestions = ref.watch(aiSmartSuggestionsProvider);
    final timeline = ref.watch(aiTimelineProvider);
    final insights = ref.watch(aiInsightsProvider);
    final macroAnalysis = ref.watch(aiMacroBreakdownProvider);
    final curatedNotes = ref.watch(aiCuratedMealNotesProvider);
    final weeklyPlan = ref.watch(weeklyPlanProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _planMeals,
        icon: const Icon(Icons.add),
        label: const Text('Add meal log'),
      ),
      body: AmbientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshMealPlan,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(child: _buildHeroStack(user, mealPlan)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    minHeight: 260,
                    maxHeight: 420,
                    child: _buildDaySelector(weeklyPlan),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildMealTimeline(timeline),
                      const SizedBox(height: AppSpacing.lg),
                      _buildMacroSnapshot(mealPlan, macroAnalysis),
                      const SizedBox(height: AppSpacing.lg),
                      _buildSmartSuggestions(smartSuggestions),
                      const SizedBox(height: AppSpacing.lg),
                      _buildQuickActions(user),
                      const SizedBox(height: AppSpacing.lg),
                      _buildInsightsSection(insights),
                      const SizedBox(height: AppSpacing.lg),
                      const HealthChecklistWidget(),
                      const SizedBox(height: AppSpacing.lg),
                      const HydrationSleepWidget(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTodaysMealPlan(mealPlan, curatedNotes),
                      const SizedBox(height: AppSpacing.xl),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStack(User? user, MealPlan? mealPlan) {
    final greeting = _getGreeting();
    final userName = user?.name.isNotEmpty == true ? user!.name.split(' ').first : 'Explorer';

    return Padding(
      padding: const EdgeInsets.only(bottom: 90),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 150),
            decoration: AppStyles.gradientDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting, $userName 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Here’s your personalized plan for today',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic_none_rounded, color: Colors.white),
                      tooltip: 'Voice assistant',
                      onPressed: _startVoiceInput,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (user?.disease != null)
                      _HeroChip(label: user!.disease!, icon: Icons.favorite_outline),
                    if (user?.fitnessGoal != null)
                      _HeroChip(label: user!.fitnessGoal!, icon: Icons.flag_outlined),
                    _HeroChip(
                      label: '${user?.targetCalories ?? AppConstants.defaultDailyCalories} kcal target',
                      icon: Icons.local_fire_department_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: -70,
            child: _buildProgressSection(user, mealPlan),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(User? user, MealPlan? mealPlan) {
    final targetCalories = (user?.targetCalories ?? AppConstants.defaultDailyCalories).toDouble();
    final consumedCalories = mealPlan?.totalCalories.toDouble() ?? 0;
    final progress = targetCalories == 0 ? 0.0 : (consumedCalories / targetCalories).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${(progress * 100).clamp(0, 999).toStringAsFixed(0)}% complete',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ProgressCircle(
                  progress: progress,
                  size: 120,
                  strokeWidth: 10,
                  backgroundColor: AppColors.surfaceAlt,
                  gradientColors: const [AppColors.primary, AppColors.secondary],
                  progressColor: AppColors.secondary,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        consumedCalories.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        'of $targetCalories kcal',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildMacroRow('Protein', mealPlan?.totalProtein ?? 0, AppColors.protein),
                    const SizedBox(height: 12),
                    _buildMacroRow('Carbs', mealPlan?.totalCarbs ?? 0, AppColors.carbs),
                    const SizedBox(height: 12),
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

  Widget _buildDaySelector(AsyncValue<List<AiWeekPlanDay>> weeklyPlan) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: DecoratedBox(
        decoration: AppStyles.cardDecoration.copyWith(
          borderRadius: AppRadius.lg,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Text(
                'Plan for the week',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Stick to the rhythm that keeps your biomarkers steady.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: _weekdays.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedDayIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDayIndex = index),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.pill,
                          color: isSelected ? AppColors.primary : AppColors.surfaceAlt.withValues(alpha: 0.7),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.surfaceAlt.withValues(alpha: 0.9),
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x3325B09C),
                                    blurRadius: 22,
                                    offset: Offset(0, 12),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _weekdays[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppDurations.fast,
                  child: weeklyPlan.when(
                    data: (days) {
                      if (days.isEmpty) {
                        return _buildWeekStatus(
                          title: 'Weekly rhythm',
                          message: 'AI studio will populate this once you log a plan.',
                          icon: Icons.auto_awesome,
                        );
                      }
                      final selected = _planForDay(days, _selectedDayIndex) ?? days.first;
                      return KeyedSubtree(key: ValueKey(selected.day), child: _buildWeekDetail(selected));
                    },
                    loading: () => KeyedSubtree(
                      key: const ValueKey('week-loading'),
                      child: _buildWeekStatus(
                        title: 'Weekly rhythm',
                        message: 'AI studio is mapping your anchors...',
                        icon: Icons.timelapse,
                      ),
                    ),
                    error: (error, _) => KeyedSubtree(
                      key: const ValueKey('week-error'),
                      child: _buildWeekStatus(
                        title: 'Weekly rhythm',
                        message: 'Unable to load plan. ${error.toString()}',
                        icon: Icons.error_outline,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekStatus({required String title, required String message, required IconData icon}) {
    return Container(
      key: ValueKey(title),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppStyles.cardDecoration.copyWith(color: AppColors.surfaceAlt),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDetail(AiWeekPlanDay day) {
    return Container(
      width: double.infinity,
      decoration: AppStyles.cardDecoration.copyWith(color: AppColors.surfaceAlt.withValues(alpha: 0.7)),
      child: ListView(
        key: ValueKey('week-${day.day}'),
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        primary: false,
        children: [
          Text(
            day.headline,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            day.focus,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          ...day.anchors.map(
            (anchor) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      anchor,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (day.mealTheme.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: AppRadius.pill,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.restaurant_menu, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      day.mealTheme,
                      style: const TextStyle(fontSize: 12, color: AppColors.primary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  AiWeekPlanDay? _planForDay(List<AiWeekPlanDay> days, int index) {
    var safeIndex = index;
    if (safeIndex < 0 || safeIndex >= _weekdays.length) {
      safeIndex = 0;
    }
    final target = _weekdays[safeIndex].substring(0, 3).toLowerCase();
    for (final entry in days) {
      final label = entry.day.toLowerCase();
      if (label.startsWith(target)) {
        return entry;
      }
    }
    return null;
  }

  Widget _buildMealTimeline(AsyncValue<List<AiTimelineEntry>> timelineAsync) {
    return timelineAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return _buildStatusCard(
            title: 'Metabolic timeline',
            message: 'Sync a meal plan to unlock time-based coaching.',
            icon: Icons.timeline,
          );
        }
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppStyles.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Metabolic timeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Container(
                      width: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: AppStyles.cardDecoration.copyWith(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.window,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.label,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.focus,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                entry.action,
                                style: const TextStyle(fontSize: 12, color: AppColors.primary, height: 1.3),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _buildStatusCard(
        title: 'Metabolic timeline',
            message: 'AI studio is sequencing your fueling windows...',
        icon: Icons.timelapse,
      ),
      error: (error, _) => _buildStatusCard(
        title: 'Metabolic timeline',
        message: 'Unable to load timeline. ${error.toString()}',
        icon: Icons.error_outline,
      ),
    );
  }

  Widget _buildMacroSnapshot(MealPlan? mealPlan, AsyncValue<AiMacroBreakdown?> macroAnalysis) {
    final macros = [
      {
        'label': 'Protein',
        'value': (mealPlan?.totalProtein ?? 0).toDouble(),
        'color': AppColors.protein,
      },
      {
        'label': 'Carbs',
        'value': (mealPlan?.totalCarbs ?? 0).toDouble(),
        'color': AppColors.carbs,
      },
      {
        'label': 'Fats',
        'value': (mealPlan?.totalFat ?? 0).toDouble(),
        'color': AppColors.fat,
      },
    ];

    final analysis = macroAnalysis.asData?.value;
    final analysisLookup = {
      for (final stat in (analysis?.macros ?? [])) stat.label.toLowerCase(): stat
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (analysis != null) ...[
            Text(
              analysis.headline,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              analysis.calorieSummary,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
          ],
          const Row(
            children: [
              Icon(Icons.speed, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Macro highlights', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: macros
                .map(
                  (macro) => Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.md,
                      color: (macro['color'] as Color).withValues(alpha: 0.08),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(macro['label']! as String,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Text(
                          '${(macro['value'] as double).toStringAsFixed(0)}g',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: macro['color'] as Color,
                            fontSize: 16,
                          ),
                        ),
                        if (analysisLookup.containsKey((macro['label'] as String).toLowerCase())) ...[
                          const SizedBox(height: 4),
                          Text(
                            analysisLookup[(macro['label'] as String).toLowerCase()]!.insight,
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          if (analysis?.callToAction.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text(
              analysis!.callToAction,
              style: const TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmartSuggestions(AsyncValue<List<AiSmartSuggestion>> suggestionsAsync) {
    return suggestionsAsync.when(
      data: (cards) {
        if (cards.isEmpty) {
          return _buildStatusCard(
            title: 'Smart suggestions',
            message: 'AI studio will surface fresh nudges after your next sync.',
            icon: Icons.lightbulb_outline,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart suggestions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PageView.builder(
                padEnds: false,
                controller: PageController(viewportFraction: 0.78),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final suggestion = cards[index];
                  final Color highlight = _suggestionColor(suggestion.category);
                  return AnimatedContainer(
                    duration: AppDurations.fast,
                    margin: const EdgeInsets.only(right: 18),
                    padding: const EdgeInsets.all(22),
                    decoration: AppStyles.cardDecoration.copyWith(
                      borderRadius: AppRadius.lg,
                      gradient: LinearGradient(
                        colors: [highlight.withValues(alpha: 0.18), Colors.white.withValues(alpha: 0.95)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F1E3C54),
                          blurRadius: 30,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: highlight.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_suggestionIcon(suggestion.category), color: highlight),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          suggestion.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            suggestion.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (suggestion.refreshHint.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            suggestion.refreshHint,
                            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => _buildStatusCard(
        title: 'Smart suggestions',
        message: 'AI studio is reading your plan...',
        icon: Icons.sync,
      ),
      error: (error, _) => _buildStatusCard(
        title: 'Smart suggestions',
        message: 'Unable to load cues. ${error.toString()}',
        icon: Icons.error_outline,
      ),
    );
  }

  Widget _buildMacroRow(String label, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        Text('${value.toStringAsFixed(0)}g', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickActions(User? user) {
    final diseaseLabel = user?.disease != null ? 'Exercises for ${user!.disease}' : 'Therapy moves';

    final actions = [
      QuickActionButton(
        icon: Icons.restaurant,
        label: 'Plan meals',
        color: AppColors.accent1,
        onPressed: _planMeals,
      ),
      QuickActionButton(
        icon: Icons.kitchen,
        label: 'Ingredient swap',
        color: AppColors.accent2,
        onPressed: _openIngredients,
      ),
      QuickActionButton(
        icon: Icons.fitness_center,
        label: diseaseLabel,
        color: AppColors.accent4,
        onPressed: () {
          final diseaseKey = user?.disease_key ?? 'knee_pain';
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DiseaseExercisesScreen(diseaseKey: diseaseKey)),
          );
        },
      ),
      QuickActionButton(
        icon: Icons.analytics_outlined,
        label: 'Nutrition analytics',
        color: AppColors.accent3,
        onPressed: _openAnalytics,
      ),
      QuickActionButton(
        icon: Icons.trending_up,
        label: 'Progress journal',
        color: AppColors.secondary,
        onPressed: _openProgress,
      ),
      QuickActionButton(
        icon: Icons.chat_bubble_outline,
        label: 'Coach chat',
        color: AppColors.primaryDark,
        onPressed: _openCoach,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) => actions[index],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(AsyncValue<List<AiInsight>> insightsAsync) {
    return insightsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildStatusCard(
            title: 'Health insights',
            message: 'No trends yet. Log meals or sync wearables to unlock AI insights.',
            icon: Icons.monitor_heart,
          );
        }
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppStyles.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Health insights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final insight = items[index];
                    return _buildFeatureTile(
                      icon: _insightIcon(insight.category),
                      title: insight.title,
                      description: '${insight.summary}\n\n${insight.action}',
                      color: _insightColor(insight.category),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _buildStatusCard(
        title: 'Health insights',
        message: 'AI studio is scanning your habits...',
        icon: Icons.sync,
      ),
      error: (error, _) => _buildStatusCard(
        title: 'Health insights',
        message: 'Unable to load insights. ${error.toString()}',
        icon: Icons.error_outline,
      ),
    );
  }

  Widget _buildTodaysMealPlan(MealPlan? mealPlan, AsyncValue<List<AiCuratedMealNote>> notesAsync) {
    final mealNotes = notesAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <AiCuratedMealNote>[],
    );

    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s curated meals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DiseaseMealPlanScreen()),
                    ),
                    icon: const Icon(Icons.view_agenda_outlined),
                    label: const Text('Open plan'),
                  ),
                  TextButton.icon(
                    onPressed: _regenerateMealPlan,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Regenerate'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (mealPlan == null)
            _buildLoadingMealCards()
          else
            _buildMealCards(mealPlan, mealNotes),
        ],
      ),
    );
  }

  Widget _buildLoadingMealCards() {
    const mealTypes = ['Breakfast', 'Lunch', 'Dinner'];
    return Column(
      children: mealTypes
          .map((type) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildLoadingMealCard(type),
              ))
          .toList(),
    );
  }

  Widget _buildLoadingMealCard(String mealType) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text('Loading $mealType recommendations...'),
        ],
      ),
    );
  }

  Widget _buildMealCards(MealPlan mealPlan, List<AiCuratedMealNote> aiNotes) {
    AiCuratedMealNote? noteFor(String type) {
      try {
        return aiNotes.firstWhere((n) => n.mealType.toLowerCase() == type.toLowerCase());
      } catch (_) {
        return null;
      }
    }

    return Column(
      children: [
        if (mealPlan.breakfast != null) ...[
          MealCard(meal: mealPlan.breakfast!, mealType: 'Breakfast', color: AppColors.accent1),
                      if (noteFor('breakfast') != null)
                        _buildMealNote(noteFor('breakfast')!),
          const SizedBox(height: 12),
        ],
        if (mealPlan.lunch != null) ...[
          MealCard(meal: mealPlan.lunch!, mealType: 'Lunch', color: AppColors.accent2),
          if (noteFor('lunch') != null)
            _buildMealNote(noteFor('lunch')!),
          const SizedBox(height: 12),
        ],
        if (mealPlan.dinner != null)
          Column(
            children: [
              MealCard(meal: mealPlan.dinner!, mealType: 'Dinner', color: AppColors.accent3),
              if (noteFor('dinner') != null)
                _buildMealNote(noteFor('dinner')!),
            ],
          ),
      ],
    );
  }

  Widget _buildMealNote(AiCuratedMealNote note) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: AppStyles.cardDecoration.copyWith(color: AppColors.surfaceAlt),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.highlight,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            note.reason,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text('${note.calories} kcal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ...note.macros.entries.map(
                (entry) => Text(
                  '${entry.key}: ${entry.value.toStringAsFixed(0)}g',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          if (note.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: note.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: AppColors.background,
                      labelStyle: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _refreshMealPlan() async {
    await ref.read(mealPlanProvider.notifier).loadTodaysMealPlan();
    ref.invalidate(aiSmartSuggestionsProvider);
    ref.invalidate(aiTimelineProvider);
    ref.invalidate(aiInsightsProvider);
    ref.invalidate(aiMacroBreakdownProvider);
    ref.invalidate(aiCuratedMealNotesProvider);
    ref.invalidate(weeklyPlanProvider);
  }

  void _regenerateMealPlan() {
    ref.read(mealPlanProvider.notifier).regenerateMealPlan();
  }

  void _planMeals() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MealSelectionScreen()),
    );
  }

  void _openIngredients() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const IngredientsScreen()));
  }

  void _openAnalytics() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionAnalyticsScreen()));
  }

  void _openProgress() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen()));
  }

  void _openCoach() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CoachChatScreen()));
  }

  Future<void> _startVoiceInput() async {
    await VoiceAssistantService.promptAndListen(
      prompt: 'Voice input ready. What would you like to do?',
      onTranscript: (_) {},
      ref: ref,
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppRadius.md,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
              maxLines: 7,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _StickyHeaderDelegate({required this.minHeight, required this.maxHeight, required this.child});

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: overlapsContent
              ? const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        child != oldDelegate.child;
  }
}

