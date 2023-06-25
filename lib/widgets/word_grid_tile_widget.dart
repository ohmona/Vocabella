import 'package:flutter/material.dart';

class WordGridTile extends StatelessWidget {
  const WordGridTile({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 0.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
