String formatNumber(int number) {
  if (number >= 1000000) {
    return "${(number / 1000000).toStringAsFixed(1)}M";
  } else if (number >= 1000) {
    return "${(number / 1000).toStringAsFixed(number % 1000 >= 100 ? 0 : 1)}K";
  }
  return number.toString();
}