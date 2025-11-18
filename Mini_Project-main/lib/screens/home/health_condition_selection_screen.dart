import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/disease_service.dart';
import 'health_recommendations_screen.dart';

class HealthConditionSelectionScreen extends ConsumerStatefulWidget {
  const HealthConditionSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HealthConditionSelectionScreen> createState() =>
      _HealthConditionSelectionScreenState();
}

class _HealthConditionSelectionScreenState
    extends ConsumerState<HealthConditionSelectionScreen> {
  late Future<List<dynamic>?> _diseasesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _diseasesFuture = DiseaseService.getAllDiseases();
  }

  Future<void> _refreshDiseases() async {
    setState(() {
      _diseasesFuture = DiseaseService.getAllDiseases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Conditions'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: _diseasesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshDiseases,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No health conditions available'),
            );
          }

          final diseases = snapshot.data!;
          final filteredDiseases = _searchQuery.isEmpty
              ? diseases
              : diseases
                  .where((disease) {
                    final title = disease['title'] as String? ?? '';
                    final description = disease['description'] as String? ?? '';
                    return title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        description.toLowerCase().contains(_searchQuery.toLowerCase());
                  })
                  .toList();

          return RefreshIndicator(
            onRefresh: _refreshDiseases,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search conditions...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),

                  // Info card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Select a health condition to get personalized diet and exercise recommendations',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // List of diseases
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredDiseases.length,
                    itemBuilder: (context, index) {
                      final disease = filteredDiseases[index];
                      return _buildDiseaseCard(context, disease);
                    },
                  ),

                  if (filteredDiseases.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conditions found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiseaseCard(BuildContext context, Map<String, dynamic> disease) {
    final title = disease['title'] as String? ?? 'Health Condition';
    final keyname = disease['keyname'] as String? ?? '';
    final description = disease['description'] as String? ?? '';

    return GestureDetector(
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.health_and_safety,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (keyname.isNotEmpty)
                          Text(
                            keyname.replaceAll('_', ' '),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ],
              ),

              // Description
              if (description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Get recommendations button
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'View Recommendations',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
