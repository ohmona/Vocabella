import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  const WordCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        border: Border.all(
          color: Theme.of(context).cardColor,
          width: 10,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).cardColor.withOpacity(0.5),
            blurRadius: 10,
            blurStyle: BlurStyle.normal,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "data",
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "data fechted! Let's go",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.audiotrack_rounded,
                size: 35,
              ),
              const SizedBox(width: 30),
              const Icon(
                Icons.audiotrack_rounded,
                size: 35,
              ),
            ],
          ),
        ],
      ),
    );
  }
}