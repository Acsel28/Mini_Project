class VoiceCommandResult {
  VoiceCommandResult({
    required this.intent,
    this.entities = const <String, dynamic>{},
    this.utterance,
    this.confidence,
  });

  final String intent;
  final Map<String, dynamic> entities;
  final String? utterance;
  final double? confidence;

  String? entityAsString(String key) => entities[key]?.toString();

  double? entityAsDouble(String key) {
    final value = entities[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int? entityAsInt(String key) {
    final value = entities[key];
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  VoiceCommandResult copyWith({
    String? intent,
    Map<String, dynamic>? entities,
    String? utterance,
    double? confidence,
  }) {
    return VoiceCommandResult(
      intent: intent ?? this.intent,
      entities: entities ?? this.entities,
      utterance: utterance ?? this.utterance,
      confidence: confidence ?? this.confidence,
    );
  }
}
