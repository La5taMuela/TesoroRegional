class LanguageLocalized {
  final String languageCode;
  final String text;

  const LanguageLocalized({
    required this.languageCode,
    required this.text,
  });

  String getLocalizedText(String languageCode) {
    // For now, just return the text since we only have one language per instance
    // In a more complex implementation, this could handle multiple languages
    return text;
  }
}
