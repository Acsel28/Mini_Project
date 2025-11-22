import 'package:flutter/material.dart';
import '../../services/disease_service.dart';

class DiseaseExercisesScreen extends StatefulWidget {
  final String diseaseKey;
  const DiseaseExercisesScreen({super.key, required this.diseaseKey});

  @override
  State<DiseaseExercisesScreen> createState() => _DiseaseExercisesScreenState();
}

class _DiseaseExercisesScreenState extends State<DiseaseExercisesScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await DiseaseService.getExercisesForDisease(widget.diseaseKey);
    setState(() {
      _data = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercises for ${widget.diseaseKey}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('No data'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_data!['recommendedExercises'] != null) ...[
                        const Text('Recommended', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        for (final e in _data!['recommendedExercises']) _exerciseCard(e),
                      ],
                      const SizedBox(height: 16),
                      if (_data!['avoidExercises'] != null) ...[
                        const Text('Avoid', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        for (final e in _data!['avoidExercises']) _exerciseCard(e, avoid: true),
                      ]
                    ],
                  ),
                ),
    );
  }

  Widget _exerciseCard(dynamic e, {bool avoid = false}) {
    return Card(
      color: avoid ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Difficulty: ${e['difficulty'] ?? 'N/A'}'),
          const SizedBox(height: 6),
          Text('Muscles: ${(e['muscles'] ?? []).join(', ')}'),
          const SizedBox(height: 6),
          Text('Steps: ${(e['steps'] ?? []).join(' | ')}'),
        ]),
      ),
    );
  }
}
