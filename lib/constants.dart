import 'package:flutter/material.dart';

const int smallDeviceWidthLimit = 500;

const double widgetHeight = 60;

const Duration expirationDuration = Duration(hours: 24);

const Color mintColor = Color(0xFF85DCC7);

const Color firstBgColor = Color(0xFF72D599);
const Color secondBgColor = Color(0xFF72BBD5);

const LinearGradient bgGradient = LinearGradient(
  begin: Alignment.topLeft,
  colors: [
    firstBgColor,
    secondBgColor,
  ],
);

List<String> languageList = [
  "en-US",
  "de-DE",
  "ko-KR",
  "fr-FR",
];

void sendToastMessage({
  required BuildContext context,
  required String msg,
  required Duration duration,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      elevation: 10,
    ),
  );
}

bool isPortraitMode({required double width, required double height}) {
  return height > width;
}