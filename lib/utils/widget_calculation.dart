
int calcPointingIndex(double position, double offset, int height) {
  return (position + offset) ~/ height;
}

int calcPointingGapIndex(double position, double offset, int height) {
  return (position + offset + (height / 2)) ~/ height;
}