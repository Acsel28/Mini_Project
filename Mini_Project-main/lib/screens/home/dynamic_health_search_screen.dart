import 'package:flutter/material.dart';
import '../../services/disease_service.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Health Conditions'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Search input
          Container(
            color: Colors.blue[50],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search for any health condition',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: _performSearch,
                  decoration: InputDecoration(
                    hintText: 'Type: knee pain, diabetes, pcos, thyroid, etc...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '💡 Type any health condition and get recommendations from our database',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Search results
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: _searchResults,
              builder: (context, snapshot) {
                // No search yet
                if (!_hasSearched) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Search for a health condition',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Examples: knee pain, diabetes, pcos, back pain',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Searching database...'),
                      ],
                    ),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _performSearch(_searchController.text);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // No results
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 64,
                          color: Colors.orange[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conditions found for "${_searchController.text}"',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try: diabetes, knee pain, pcos, thyroid, obesity',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Results found
                final results = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final condition = results[index];
                    final title = condition['title'] as String? ?? 'Unknown';
                    final description =
                        condition['description'] as String? ?? '';
                    final keyname = condition['keyname'] as String? ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HealthRecommendationsScreen(
                              diseaseKey: keyname,
                              diseaseName: title,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue[400]!,
                                Colors.blue[600]!,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (description.isNotEmpty)
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: const Text('View Details'),
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Tap to see diet & exercises',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
