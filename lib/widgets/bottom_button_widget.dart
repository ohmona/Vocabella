import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  const BottomButton(
      {Key? key,
        required this.size,
        required this.bBig,
        required this.onPressed,
        required this.icon})
      : super(key: key);

  final double size;
  final bool bBig;
  final void Function() onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(90)),
          ),
          alignment: Alignment.center,
          backgroundColor: Theme.of(context).cardColor,
          shadowColor: CupertinoColors.black.withOpacity(0),
          elevation: 1,
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          size: bBig ? 75 : 25,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.white,
              blurRadius: bBig ? 10 : 5,
            ),
          ],
        ),
      ),
    );
  }
}