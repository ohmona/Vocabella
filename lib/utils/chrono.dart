Duration calcLastedTime(DateTime start, DateTime finish) {
  var interval = finish.difference(start);
  return interval;
}

String formatLastedTime(Duration duration) {
  int hours = duration.inHours;
  int minutes = duration.inMinutes % 60;
  int seconds = duration.inSeconds % 60;

  if (hours > 0) {
    return "${hours}h ${minutes}min ${seconds}s";
  } else if (minutes > 0) {
    return "${minutes}min ${seconds}s";
  } else {
    return "${seconds}s";
  }
}

String formatDay(DateTime date) {
  return "${date.year}, ${date.month} ${date.day}";
}

bool areTheSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

bool isPastDay(DateTime target, DateTime comparison) {
  return target.year < comparison.year ||
      target.month < comparison.month ||
      target.day < comparison.day;
}

bool isFutureDay(DateTime target, DateTime comparison) {
  return target.year > comparison.year ||
      target.month > comparison.month ||
      target.day > comparison.day;
}