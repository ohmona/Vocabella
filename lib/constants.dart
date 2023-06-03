import 'package:flutter/material.dart';

class AnimValue {
  AnimValue({
    this.mainOffset = const Offset(0, 0),
    this.mainHiddenOffset = const Offset(0, 1000),
    this.smallOffset = const Offset(0, 0),
    this.mediumOffset = const Offset(0, 340),
    this.oneOpacity = 1,
    this.zeroOpacity = 0,
    this.defaultWidth = 400,
    this.smallWidth = 400,
    this.mediumWidth = 400,
    this.defaultHeight = 800,
    this.smallHeight = 320,
    this.mediumHeight = 320,
    this.defaultScale = 1,
    this.smallScale = 1,
    this.mediumScale = 1,
  });

  AnimValue.sized({
    this.mainOffset = const Offset(0, 0),
    this.mainHiddenOffset = const Offset(0, 1000),
    this.smallOffset = const Offset(0,0),
    this.mediumOffset = const Offset(60,130),
    this.oneOpacity = 1,
    this.zeroOpacity = 0,
    this.defaultWidth = 400,
    this.smallWidth = 200,
    this.mediumWidth = 350,
    this.defaultHeight = 800,
    this.smallHeight = 300,
    this.mediumHeight = 580,
    this.defaultScale = 1,
    this.smallScale = 0.8,
    this.mediumScale = 0.8,
  });

  AnimValue.flip({
    this.mainOffset = const Offset(0, 0),
    this.mainHiddenOffset = const Offset(0, 1000),
    this.smallOffset = const Offset(0, 340),
    this.mediumOffset = const Offset(0, 0),
    this.oneOpacity = 1,
    this.zeroOpacity = 0,
    this.defaultWidth = 400,
    this.smallWidth = 400,
    this.mediumWidth = 400,
    this.defaultHeight = 800,
    this.smallHeight = 320,
    this.mediumHeight = 320,
    this.defaultScale = 1,
    this.smallScale = 1,
    this.mediumScale = 1,
  });

  Offset mainOffset;
  Offset mainHiddenOffset;
  Offset smallOffset;
  Offset mediumOffset;

  double oneOpacity;
  double zeroOpacity;

  double defaultWidth;
  double smallWidth;
  double mediumWidth;

  double defaultHeight;
  double smallHeight;
  double mediumHeight;

  double defaultScale;
  double smallScale;
  double mediumScale;
}
