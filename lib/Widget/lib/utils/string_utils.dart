class StringUtils {
  static String limitWords(String text, int maxWords) {
    List<String> words = text.split(' ');
    if (words.length > maxWords) {
      return words.sublist(0, maxWords).join(' ') + '...';
    }
    return text;
  }
}
