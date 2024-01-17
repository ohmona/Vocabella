
import 'dart:math';
import 'package:flutter/foundation.dart';

String generateRandomString(int len) {
  var r = Random();
  const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final str = List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  if (kDebugMode) {
    print("random string generated : $str");
  }
  return str;
}