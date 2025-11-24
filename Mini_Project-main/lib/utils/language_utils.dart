String normalizeLanguage(String? value) {
  final normalized = (value ?? '').trim().toLowerCase();
  if (normalized.contains('hind')) {
    return 'hindi';
  }
  return 'english';
}

bool isHindiLanguage(String? value) {
  return normalizeLanguage(value) == 'hindi';
}

String languageDisplayLabel(String? value) {
  return isHindiLanguage(value) ? 'हिन्दी' : 'English';
}
