String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
  String minutes = twoDigits(duration.inMinutes.remainder(60));
  String seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$hours$minutes:$seconds";
}
