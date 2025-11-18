import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/health_service.dart';

class HealthChecklistWidget extends ConsumerStatefulWidget {
  const HealthChecklistWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<HealthChecklistWidget> createState() => _HealthChecklistWidgetState();
}

class _HealthChecklistWidgetState extends ConsumerState<HealthChecklistWidget> {
  List<dynamic>? _checklist;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchChecklist();
  }

  Future<void> _fetchChecklist() async {
    setState(() => _loading = true);
    final data = await HealthService.getChecklist();
    setState(() {
      _checklist = data;
      _loading = false;
    });
  }

  Future<void> _toggleItem(int idx) async {
    if (_checklist == null) return;
    final item = _checklist![idx];
    final updated = !(item['done'] as bool);
    await HealthService.updateChecklist(item['label'], updated);
    await _fetchChecklist();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_checklist == null) {
      return const Center(child: Text('Could not load checklist.'));
    }
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Health Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            ...List.generate(_checklist!.length, (i) {
              final item = _checklist![i];
              return CheckboxListTile(
                value: item['done'] as bool,
                title: Text(item['label']),
                onChanged: (_) => _toggleItem(i),
              );
            }),
          ],
        ),
      ),
    );
  }
}
