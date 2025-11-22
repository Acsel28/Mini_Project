import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design_system.dart';
import '../core/theme.dart';
import '../services/health_service.dart';

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily health checklist',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh checklist',
                onPressed: _fetchChecklist,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_checklist == null)
            const Text('Could not load checklist. Please try again later.')
          else
            Column(
              children: List.generate(_checklist!.length, (i) {
                final item = _checklist![i];
                final done = item['done'] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: done ? AppColors.success.withValues(alpha: 0.08) : AppColors.surfaceAlt,
                    borderRadius: AppRadius.md,
                    border: Border.all(
                      color: done
                          ? AppColors.success.withValues(alpha: 0.2)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: done,
                        onChanged: (_) => _toggleItem(i),
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.success;
                          }
                          return AppColors.surface;
                        }),
                        checkColor: Colors.white,
                        overlayColor: WidgetStateProperty.all(
                          AppColors.success.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['label'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: done ? AppColors.success : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
