
Duration calcLastedTime(DateTime start, DateTime finish) {
  var interval = finish.difference(start);
  return interval;
}

String formatLastedTime(Duration duration) {
  int hours = duration.inHours;
  int minutes = duration.inMinutes % 60;
  int seconds = duration.inSeconds % 60;

  if(hours > 0) {
    return "${hours}h ${minutes}min ${seconds}s";
  }
  else if(minutes > 0) {
    return "${minutes}min ${seconds}s";
  }
  else {
    return "${seconds}s";
  }
}