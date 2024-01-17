import 'package:flutter/material.dart';

const String idSeparator = "/-{o[w]n}-/";

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
  "ko-KR",
  "ar-AE",
  "be-BY",
  "bs-BA",
  "cs-CZ",
  "da-DK",
  "de-DE",
  "el-GR",
  "en-US",
  "es-ES",
  "et-EE",
  "fi-FI",
  "fr-FR",
  "he-IL",
  "hi-IN",
  "hr-HR",
  "hu-HU",
  "hy-AM",
  "id-ID",
  "is-IS",
  "it-IT",
  "ja-JP",
  "ka-GE",
  "lt-LT",
  "lv-LV",
  "mk-MK",
  "nl-NL",
  "no-NO",
  "pl-PL",
  "pt-BR",
  "pt-PT",
  "ro-RO",
  "ru-RU",
  "sk-SK",
  "sl-SI",
  "sq-AL",
  "sr-RS",
  "sv-SE",
  "th-TH",
  "tr-TR",
  "uk-UA",
  "vi-VN",
  "zh-CN",
  "zh-TW",
];

String makeSubjectId({required String date, required String name}) {
  return "$date$idSeparator$name";
}

String makeWordPairId({required int id, required String name}) {
  return "$id$idSeparator$name";
}

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