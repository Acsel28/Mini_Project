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
  const DynamicHealthSearchScreen({Key? key, this.initialQuery}) : super(key: key);

  final String? initialQuery;

  @override
  State<DynamicHealthSearchScreen> createState() =>
      _DynamicHealthSearchScreenState();
}

class _DynamicHealthSearchScreenState extends State<DynamicHealthSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<Map<String, dynamic>?>? _insightFuture;
  bool _hasSearched = false;
  String? _activeQuery;

  @override
  void initState() {
    super.initState();
    _insightFuture = null;
    _searchController.addListener(_onSearchFieldChanged);

    final prefill = widget.initialQuery?.trim();
    if (prefill != null && prefill.isNotEmpty) {
      _searchController.text = prefill;
      WidgetsBinding.instance.addPostFrameCallback((_) => _performSearch(prefill));
    }
  }

  void _onSearchFieldChanged() => setState(() {});

  void _performSearch(String? rawQuery) {
    final query = (rawQuery ?? _searchController.text).trim();

    if (query.isEmpty) {
      setState(() {
        _hasSearched = false;
        _activeQuery = null;
        _insightFuture = null;
      });
      return;
    }

    setState(() {
      _hasSearched = true;
      _activeQuery = query;
      _insightFuture = DiseaseService.getConditionInsights(query);
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
                  onSubmitted: (value) => _performSearch(value),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Try: diabetes, thyroid, knee pain…',
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryDark),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.send,
                              color: _searchController.text.trim().isEmpty
                                  ? AppColors.textTertiary
                                  : AppColors.primary),
                          onPressed: _searchController.text.trim().isEmpty
                              ? null
                              : () => _performSearch(_searchController.text),
                        ),
                      ],
                    ),
                    suffixIconConstraints:
                        const BoxConstraints(minHeight: 0, minWidth: 0),
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
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _insightFuture,
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
                    title: 'Designing your precision plan…',
                    subtitle: 'Pulling nutrition and movement cues for ${_activeQuery ?? _searchController.text}',
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

                final data = snapshot.data;
                if (data == null) {
                  return _buildIllustratedState(
                    icon: Icons.info_outline,
                    title: 'No insights yet',
                    subtitle: 'Try searching for another condition (e.g., diabetes, PCOS, thyroid).',
                  );
                }

                return _buildInsightView(context, data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightView(BuildContext context, Map<String, dynamic> data) {
    final answer = data['answer'];
    if (answer is! Map<String, dynamic>) {
      return _buildIllustratedState(
        icon: Icons.info_outline,
        title: 'We could not parse the response',
        subtitle: 'Please try again in a moment.',
        action: TextButton(
          onPressed: () => _performSearch(_activeQuery ?? _searchController.text),
          child: const Text('Refresh insights'),
        ),
      );
    }

    final summary = (answer['condition_summary'] as String? ?? '').trim();
    final dietGuidance = _stringList(answer['diet_guidance']);
    final exercisePlan = _stringList(answer['exercise_plan']);
    final lifestyleHooks = _stringList(answer['lifestyle_hooks']);
    final reminders = _stringList(answer['reminders']);
    final riskFlags = _stringList(answer['risk_flags']);
    final references = _stringList(answer['references']);
    final facts = (data['facts'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final memoryTrail = (data['memoryTrail'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final source = data['source'] as String?;
    final note = data['error'] as String?;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSummaryCard(
          summary: summary.isEmpty ? 'Structured guidance ready.' : summary,
          source: source,
          query: data['query'] as String? ?? _activeQuery,
          riskFlags: riskFlags,
          note: note,
        ),
        _buildInsightSection(
          title: 'Nutrition cues',
          icon: Icons.restaurant_menu,
          iconColor: AppColors.primary,
          items: dietGuidance,
        ),
        _buildInsightSection(
          title: 'Movement plan',
          icon: Icons.self_improvement,
          iconColor: AppColors.accent2,
          items: exercisePlan,
        ),
        _buildInsightSection(
          title: 'Lifestyle & mindfulness',
          icon: Icons.spa,
          iconColor: AppColors.accent4,
          items: lifestyleHooks,
        ),
        _buildInsightSection(
          title: 'Daily reminders',
          icon: Icons.alarm,
          iconColor: AppColors.accent3,
          items: reminders,
        ),
        if (references.isNotEmpty)
          _buildChipWrap(
            title: 'Reference anchors',
            icon: Icons.link,
            values: references,
          ),
        if (facts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Text(
              'Clinical backing',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ...facts.map((fact) => _buildFactCard(context, fact)).toList(),
        ],
        if (memoryTrail.isNotEmpty)
          _buildChipWrap(
            title: 'Recent searches',
            icon: Icons.history,
            values: memoryTrail
                .map((row) => row['query']?.toString() ?? '')
                .where((value) => value.trim().isNotEmpty)
                .cast<String>()
                .toList(),
          ),
      ].whereType<Widget>().toList(),
    );
  }

  Widget _buildSummaryCard({
    required String summary,
    required List<String> riskFlags,
    String? source,
    String? query,
    String? note,
  }) {
    final sourceLabel = () {
      switch (source) {
        case 'cache':
          return 'Recent insight';
        case 'db_fallback':
          return 'Library data';
        case 'llm':
          return 'AI + clinical DB';
        default:
          return 'Insight';
      }
    }();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: AppInsets.card,
      decoration: AppStyles.cardDecoration.copyWith(
        gradient: LinearGradient(
          colors: [AppColors.accent4.withValues(alpha: 0.25), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  query ?? 'Condition insight',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Chip(
                label: Text(sourceLabel),
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: const TextStyle(height: 1.4),
          ),
          if (note != null) ...[
            const SizedBox(height: 12),
            Text(
              'Note: $note',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
          if (riskFlags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: riskFlags
                  .map(
                    (risk) => Chip(
                      label: Text(risk),
                      backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                      labelStyle: const TextStyle(color: AppColors.warning),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightSection({
    required String title,
    required IconData icon,
    required List<String> items,
    Color iconColor = AppColors.primary,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: AppInsets.card,
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipWrap({
    required String title,
    required IconData icon,
    required List<String> values,
  }) {
    final chips = values
        .where((value) => value.trim().isNotEmpty)
        .map((value) => Chip(
              label: Text(value),
              backgroundColor: AppColors.surfaceAlt,
            ))
        .toList();

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: AppInsets.card,
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips,
          ),
        ],
      ),
    );
  }

  Widget _buildFactCard(BuildContext context, Map<String, dynamic> fact) {
    final title = fact['title']?.toString() ?? 'Condition';
    final description = fact['description']?.toString() ?? '';
    final keyname = fact['key']?.toString() ?? '';
    final dietHighlights = _stringList(fact['diet_recommended']).take(4).toList();
    final exerciseHighlights = _extractExerciseNames(
      (fact['exercises'] as Map<String, dynamic>?)?['recommended'],
    ).take(3).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: AppInsets.card,
      decoration: AppStyles.cardDecoration.copyWith(
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.3),
            ),
          ],
          if (dietHighlights.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Diet anchors',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dietHighlights
                  .map((food) => Chip(
                        label: Text(food),
                        backgroundColor: AppColors.surfaceAlt,
                      ))
                  .toList(),
            ),
          ],
          if (exerciseHighlights.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Movement focus',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            ...exerciseHighlights.map(
              (exercise) => Row(
                children: [
                  const Icon(Icons.check, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      exercise,
                      style: const TextStyle(height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View full protocol'),
              onPressed: keyname.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HealthRecommendationsScreen(
                            diseaseKey: keyname,
                            diseaseName: title,
                          ),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _stringList(dynamic value) {
    if (value is Iterable) {
      return value
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .cast<String>()
          .toList();
    }
    return const [];
  }

  List<String> _extractExerciseNames(dynamic value) {
    if (value is Iterable) {
      return value
          .map((item) {
            if (item is Map<String, dynamic>) {
              return item['name']?.toString() ?? '';
            }
            return item?.toString() ?? '';
          })
          .where((item) => item.trim().isNotEmpty)
          .cast<String>()
          .toList();
    }
    return const [];
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
    _searchController.removeListener(_onSearchFieldChanged);
    _searchController.dispose();
    super.dispose();
  }
}
