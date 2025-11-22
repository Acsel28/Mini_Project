import 'package:flutter/material.dart';
import '../../core/design_system.dart';
import '../../core/theme.dart';
import '../../services/disease_service.dart';
import '../../widgets/wellness_scaffold.dart';
import 'health_recommendations_screen.dart';

/// REAL INTEGRATION: User inputs ANY health condition → Database query → Results
/// No pre-selected conditions, no toggles
/// User types/searches for ANY condition → Gets results from database
class DynamicHealthSearchScreen extends StatefulWidget {
  const DynamicHealthSearchScreen({Key? key}) : super(key: key);

  @override
  State<DynamicHealthSearchScreen> createState() =>
      _DynamicHealthSearchScreenState();
}

class _DynamicHealthSearchScreenState extends State<DynamicHealthSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<dynamic>?> _searchResults;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchResults = Future.value(null);
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _hasSearched = false;
        _searchResults = Future.value(null);
      });
      return;
    }

    setState(() {
      _hasSearched = true;
      _searchResults = DiseaseService.searchDiseases(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WellnessScaffold(
      title: 'Smart condition search',
      subtitle: 'Type any symptom to get a science-backed plan',
      implyLeading: false,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: AppInsets.card,
            decoration: AppStyles.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search for any health concern',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: _performSearch,
                  onSubmitted: _performSearch,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Try: diabetes, thyroid, knee pain…',
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryDark),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.lg,
                      borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.15)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.lg,
                      borderSide: BorderSide(color: AppColors.primary, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '💡 We match your search with curated diet, movement, and mindfulness plans.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: _searchResults,
              builder: (context, snapshot) {
                if (!_hasSearched) {
                  return _buildIllustratedState(
                    icon: Icons.travel_explore,
                    title: 'Search for a health condition',
                    subtitle: 'Type any condition to get tailored nutrition & movement protocols.',
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildIllustratedState(
                    icon: Icons.hourglass_bottom,
                    title: 'Scanning clinical library…',
                    subtitle: 'Pulling precision plans for ${_searchController.text}',
                    showLoader: true,
                  );
                }

                if (snapshot.hasError) {
                  return _buildIllustratedState(
                    icon: Icons.error_outline,
                    title: 'Something went wrong',
                    subtitle: snapshot.error.toString(),
                    action: TextButton(
                      onPressed: () => _performSearch(_searchController.text),
                      child: const Text('Retry search'),
                    ),
                  );
                }

                final results = snapshot.data ?? [];
                if (results.isEmpty) {
                  return _buildIllustratedState(
                    icon: Icons.info_outline,
                    title: 'No matches found',
                    subtitle: 'Try terms like diabetes, PCOS, thyroid, stress, or gut health.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final condition = results[index];
                    final title = condition['title'] as String? ?? 'Unknown';
                    final description = condition['description'] as String? ?? '';
                    final keyname = condition['keyname'] as String? ?? '';

                    return InkWell(
                      borderRadius: AppRadius.lg,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HealthRecommendationsScreen(
                              diseaseKey: keyname,
                              diseaseName: title,
                            ),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        padding: AppInsets.card,
                        decoration: AppStyles.cardDecoration.copyWith(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent4.withValues(alpha: 0.28),
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                              ],
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                description,
                                style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: const [
                                Icon(Icons.bolt, size: 16, color: AppColors.primary),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Tap to view nutrition, workouts, and mindfulness cues for this condition.',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustratedState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
    bool showLoader = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.6)),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (showLoader) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
          if (action != null) ...[
            const SizedBox(height: 16),
            action,
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
