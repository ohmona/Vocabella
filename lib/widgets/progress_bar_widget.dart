import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).cardColor.withOpacity(0.5),
            blurRadius: 10,
            blurStyle: BlurStyle.normal,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      height: MediaQuery.of(context).size.height * 0.09,
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.09 / 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 10,
                      blurStyle: BlurStyle.normal,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 30,
            ),
            Transform.scale(
              scale: 1.5,
              child: Text(
                "1/3",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: (MediaQuery.of(context).size.height * 0.02)),
              ),
            )
          ],
        ),
      ),
    );
  }
}