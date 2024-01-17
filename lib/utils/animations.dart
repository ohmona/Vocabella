import 'package:flutter/material.dart';
import 'constants.dart';

class AnimValueBase {
  AnimValueBase()
      : mainOffset = const Offset(0, 0),
        mainHiddenOffset = const Offset(0, 1000),
        smallOffset = const Offset(0, 0),
        mediumOffset = const Offset(0, 340),
        oneOpacity = 1,
        zeroOpacity = 0,
        defaultWidth = 400,
        smallWidth = 400,
        mediumWidth = 400,
        defaultHeight = 800,
        smallHeight = 320,
        mediumHeight = 320,
        defaultScale = 1,
        smallScale = 1,
        mediumScale = 1 {
    Size size = WidgetsBinding.instance.window.physicalSize;
    double ratio = WidgetsBinding.instance.window.devicePixelRatio;

    double width = size.width / ratio;
    double height = size.height / ratio;

    double totalBarsHeight = 2 * widgetHeight;
    double freeHeight = height - totalBarsHeight - 40;

    defaultWidth = width;
    defaultHeight = freeHeight;
    smallWidth = defaultWidth;
    mediumWidth = defaultWidth;
    mediumOffset = Offset(0, freeHeight / 2);
    smallHeight = freeHeight / 2 - 25;
    mediumHeight = freeHeight / 2 - 25;
  }

  late Offset mainOffset;
  late Offset mainHiddenOffset;
  late Offset smallOffset;
  late Offset mediumOffset;

  late double oneOpacity;
  late double zeroOpacity;

  late double defaultWidth;
  late double smallWidth;
  late double mediumWidth;

  late double defaultHeight;
  late double smallHeight;
  late double mediumHeight;

  late double defaultScale;
  late double smallScale;
  late double mediumScale;
}

class DefaultAnimValue extends AnimValueBase {
  DefaultAnimValue() : super();
}

class DefaultLandscapeAnimValue extends AnimValueBase {
  DefaultLandscapeAnimValue() : super() {
    Size size = WidgetsBinding.instance.window.physicalSize;
    double ratio = WidgetsBinding.instance.window.devicePixelRatio;

    double width = size.width / ratio;
    double height = size.height / ratio;

    double totalBarsHeight = height * 0.18;
    double freeHeight = height - totalBarsHeight - 40;

    defaultWidth = width;
    defaultHeight = freeHeight;
    smallWidth = (defaultWidth / 2) - 20;
    smallOffset = const Offset(15, 0);
    mediumWidth = (defaultWidth / 2) - 20;
    mediumOffset = Offset((defaultWidth / 2) + 10, 0);
    smallHeight = defaultHeight;
    mediumHeight = defaultHeight;
  }
}

// TODO implement this for any device
class _SizedAnimValue extends AnimValueBase {

  // Don't use this
  _SizedAnimValue() : super() {
    mediumOffset = const Offset(60, 130);
    smallWidth = 200;
    mediumWidth = 350;
    smallHeight = 300;
    mediumHeight = 580;
    smallScale = 0.8;
    mediumScale = 0.8;
  }
}

void bruh() {
  _SizedAnimValue();
}