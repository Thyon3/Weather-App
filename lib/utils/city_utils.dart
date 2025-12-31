String normalizeCity(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';
  final words = trimmed
      .split(RegExp(r'\s+'))
      .map(
        (word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase(),
      )
      .toList();
  return words.join(' ');
}
