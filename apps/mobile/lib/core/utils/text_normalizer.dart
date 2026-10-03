/// Text as the app compares it: trimmed, lowercase and without Spanish
/// accents, so `Café`, `cafe` and ` CAFÉ ` are the same category or search.
abstract final class TextNormalizer {
  static const Map<String, String> _accents = <String, String>{
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'ñ': 'n',
  };

  static String normalize(String text) {
    final StringBuffer buffer = StringBuffer();
    for (final String char in text.trim().toLowerCase().split('')) {
      buffer.write(_accents[char] ?? char);
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
  }
}
