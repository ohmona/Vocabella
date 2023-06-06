import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

const double _widgetHeight = 60;

class ProgressBar extends StatelessWidget {
  const ProgressBar({Key? key, required this.total, required this.progress})
      : super(key: key);

  final int total, progress;

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
      height: _widgetHeight,
      child: Padding(
        padding: const EdgeInsets.all(_widgetHeight / 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor,
                      blurRadius: 15,
                    )
                  ],
                ),
                child: LinearPercentIndicator(
                  animation: true,
                  lineHeight: 20.0,
                  animationDuration: 1000,
                  percent: progress / total,
                  barRadius: const Radius.circular(45),
                  progressColor: Theme.of(context).primaryColor,
                  curve: Curves.easeOutSine,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Transform.scale(
              scale: 1.5,
              child: Text(
                "$progress/$total",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
