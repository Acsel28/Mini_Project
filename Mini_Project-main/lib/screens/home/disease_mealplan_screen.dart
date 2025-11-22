import 'package:flutter/material.dart';
import '../../services/mealplan_service.dart';

class DiseaseMealPlanScreen extends StatefulWidget {
  const DiseaseMealPlanScreen({super.key});

  @override
  State<DiseaseMealPlanScreen> createState() => _DiseaseMealPlanScreenState();
}

class _DiseaseMealPlanScreenState extends State<DiseaseMealPlanScreen> {
  Map<String, dynamic>? _plan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() => _loading = true);
    final plan = await MealPlanService.generateForUser();
    setState(() {
      _plan = plan;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalised Meal Plan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _plan == null
              ? const Center(child: Text('No plan generated'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Calories target: ${_plan!['calorieTarget'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._buildSlot('Breakfast', _plan!['slots']['breakfast']),
                    const SizedBox(height: 12),
                    ..._buildSlot('Lunch', _plan!['slots']['lunch']),
                    const SizedBox(height: 12),
                    ..._buildSlot('Dinner', _plan!['slots']['dinner']),
                    const SizedBox(height: 12),
                    ..._buildSlot('Snacks', _plan!['slots']['snacks']),
                  ]),
                ),
    );
  }

  List<Widget> _buildSlot(String title, dynamic items) {
    final list = (items as List<dynamic>?) ?? [];
    return [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      for (final m in list)
        Card(
          child: ListTile(
            title: Text(m['title'] ?? 'Untitled'),
            subtitle: Text('${m['calories'] ?? 0} kcal | Protein: ${m['protein'] ?? 0}g'),
          ),
        )
    ];
  }
}
