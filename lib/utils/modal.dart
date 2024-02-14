
import 'package:flutter/material.dart';

import 'constants.dart';

void openAlert(BuildContext context, {required String title, required String content}) {
  Future.delayed(const Duration(milliseconds: 1), () {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: mintColor,
              ),
              child: const Text("ok"),
            ),
          ],
        );
      },
    );
  });
}