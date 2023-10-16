subStringName(String text, int maxLen) {
  if (text.length <= maxLen) {
    return text;
  } else {
    return '${text.substring(0, maxLen)} ...';
  }
}
