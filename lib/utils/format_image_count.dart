formatImageCount(int count) {
  if (count < 1000) {
    return count.toString();
  } else {
    final double thousands = count / 1000;
    return "${thousands.toStringAsFixed(1)}k";
  }
}
