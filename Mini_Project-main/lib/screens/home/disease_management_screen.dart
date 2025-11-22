import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/disease_model.dart';
import '../../providers/disease_provider.dart';
import '../../widgets/app_styles_extended.dart';
import '../../widgets/reusable_components.dart';
import '../../widgets/disease_detail_widgets.dart';

class DiseaseManagementScreen extends ConsumerStatefulWidget {
  const DiseaseManagementScreen({super.key});

  @override
  ConsumerState<DiseaseManagementScreen> createState() => _DiseaseManagementScreenState();
}

class _DiseaseManagementScreenState extends ConsumerState<DiseaseManagementScreen> {
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final selectedDiseaseKeys = ref.watch(selectedDiseasesProvider);
    final diseaseList = _searchQuery.isEmpty
        ? ref.watch(diseaseListProvider)
        : ref.watch(diseaseSearchProvider(_searchQuery));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                autofocus: true,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search conditions...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(color: AppColors.textPrimary),
              )
            : const Text('My Health Conditions'),
        actions: [
          if (!_showSearch)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _showSearch = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _showSearch = false;
                _searchQuery = '';
              }),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: PaddingValues.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Diseases Section
            if (selectedDiseaseKeys.isNotEmpty) ...[
              SectionHeader(
                title: 'Your Conditions (${selectedDiseaseKeys.length})',
                actionText: 'Clear All',
                onActionTap: _showClearAllDialog,
              ),
              AppStylesExtended.gapLg,
              Wrap(
                spacing: AppStylesExtended.md,
                runSpacing: AppStylesExtended.md,
                children: [
                  for (final diseaseKey in selectedDiseaseKeys)
                    DiseaseTag(
                      name: diseaseKey.replaceAll('_', ' ').toUpperCase(),
                      color: AppColors.primary,
                      onTap: () => _showDiseaseDetail(diseaseKey),
                      onRemove: () => ref
                          .read(selectedDiseasesProvider.notifier)
                          .deselectDisease(diseaseKey),
                    ),
                ],
              ),
              AppStylesExtended.gapXxl,
            ],

            // Unified Recommendations
            if (selectedDiseaseKeys.isNotEmpty) ...[
              _buildUnifiedRecommendations(),
              AppStylesExtended.gapXxl,
            ],

            // Browse All Conditions
            SectionHeader(
              title: 'Explore Conditions',
              actionText: 'All',
            ),
            AppStylesExtended.gapLg,
            diseaseList.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => EmptyState(
                icon: Icons.error_outline,
                title: 'Error Loading Conditions',
                message: error.toString(),
              ),
              data: (diseases) {
                if (diseases.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'No Conditions Found',
                    message: 'Try adjusting your search query',
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: diseases.length,
                  separatorBuilder: (_, __) => AppStylesExtended.gapMd,
                  itemBuilder: (context, index) {
                    final disease = diseases[index];
                    final isSelected = selectedDiseaseKeys.contains(disease.keyname);

                    return _buildDiseaseCard(disease, isSelected);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseCard(Disease disease, bool isSelected) {
    return GestureDetector(
      onTap: () => _showDiseaseDetail(disease.keyname),
      child: Container(
        padding: PaddingValues.lg,
        decoration: AppStylesExtended.containerDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disease.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      AppStylesExtended.gapSm,
                      Text(
                        disease.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleDisease(disease.keyname),
                    ),
                    const Text('Select', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            AppStylesExtended.gapMd,
            Row(
              children: [
                _buildInfoChip('🍽️', 'Diet'),
                AppStylesExtended.gapHMd,
                _buildInfoChip('🏃', 'Exercises'),
                AppStylesExtended.gapHMd,
                _buildInfoChip('💡', 'Tips'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppStylesExtended.radiusSm),
      ),
      child: Text(
        '$icon $label',
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUnifiedRecommendations() {
    final selectedDiseaseKeys = ref.watch(selectedDiseasesProvider);
    final unifiedDiet = ref.watch(unifiedDietRecommendationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Unified Recommendations'),
        AppStylesExtended.gapLg,
        Container(
          padding: PaddingValues.lg,
          decoration: AppStylesExtended.containerDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  AppStylesExtended.gapHMd,
                  Expanded(
                    child: Text(
                      'Recommendations for ${selectedDiseaseKeys.length} condition${selectedDiseaseKeys.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              AppStylesExtended.gapLg,
              unifiedDiet.when(
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Text(
                  'Error loading recommendations: $error',
                  style: const TextStyle(color: AppColors.error),
                ),
                data: (diet) {
                  final recommendedFoods = diet['recommendedFoods'] as List<dynamic>? ?? [];
                  final avoidFoods = diet['avoidFoods'] as List<dynamic>? ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecommendationSection(
                        '✅ Foods to Include',
                        recommendedFoods.map((e) => e.toString()).toList(),
                        AppColors.success,
                      ),
                      AppStylesExtended.gapLg,
                      _buildRecommendationSection(
                        '❌ Foods to Avoid',
                        avoidFoods.map((e) => e.toString()).toList(),
                        AppColors.error,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection(
    String title,
    List<String> items,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        AppStylesExtended.gapMd,
        Wrap(
          spacing: AppStylesExtended.sm,
          runSpacing: AppStylesExtended.sm,
          children: [
            for (final item in items.where((i) => i.isNotEmpty))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppStylesExtended.radiusLg),
                ),
                child: Text(
                  item.trim(),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _toggleDisease(String diseaseKey) {
    final notifier = ref.read(selectedDiseasesProvider.notifier);
    final selectedDiseaseKeys = ref.read(selectedDiseasesProvider);

    if (selectedDiseaseKeys.contains(diseaseKey)) {
      notifier.deselectDisease(diseaseKey);
    } else {
      notifier.selectDisease(diseaseKey);
    }
  }

  void _showDiseaseDetail(String diseaseKey) {
    final profileAsync = ref.watch(fullDiseaseProfileProvider(diseaseKey));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => profileAsync.when(
        loading: () => const SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => SizedBox(
          height: 300,
          child: Center(
            child: Text('Error: $error'),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const SizedBox(
              height: 300,
              child: Center(child: Text('No data available')),
            );
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              padding: PaddingValues.lg,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          profile.disease.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  AppStylesExtended.gapXl,
                  if (profile.diet != null) ...[
                    DietDetailsWidget(diet: profile.diet!),
                    AppStylesExtended.gapXl,
                  ],
                  if (profile.exercise != null) ...[
                    ExerciseDetailsWidget(
                      recommendations: profile.exercise!,
                    ),
                    AppStylesExtended.gapXl,
                  ],
                  LifestyleGuidanceWidget(
                    guidance: profile.lifestyle,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Conditions'),
        content: const Text('Are you sure you want to remove all selected conditions?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(selectedDiseasesProvider.notifier).clearSelection();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
