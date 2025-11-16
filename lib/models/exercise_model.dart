class Exercise {
  final String id;
  final String name;
  final String duration;
  final String intensity;
  final String frequency;
  final String description;
  final String? caution;

  const Exercise({
    required this.id,
    required this.name,
    required this.duration,
    required this.intensity,
    required this.frequency,
    required this.description,
    this.caution,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      duration: (map['duration'] ?? '').toString(),
      intensity: (map['intensity'] ?? '').toString(),
      frequency: (map['frequency'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      caution: map['caution']?.toString(),
    );
  }
}
