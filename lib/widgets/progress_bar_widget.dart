import 'package:flutter/material.dart';

const double _widgetHeight = 60;

class ProgressBar extends StatefulWidget {
  const ProgressBar({Key? key, required this.total, required this.progress})
      : super(key: key);

  final int total, progress;
  //late void Function(int, int) updateProgress;

  @override
  State<ProgressBar> createState() => ProgressBarState();
}

class ProgressBarState extends State<ProgressBar> with TickerProviderStateMixin {
  int progress = 0;
  int total = 0;

  double animationProgress = 0;

  bool bAnimating = false;

  late AnimationController controller;
  late Animation<double> animation;

  void updateProgress(int total, int progress) {
    setState(() {
      this.progress = progress;
      this.total = total;
    });
    animateToNext();
  }

  // Animate Progressbar to next number
  void animateToNext() {
    bAnimating = true;
    final Animation<double> curve = CurvedAnimation(parent: controller, curve: Curves.linear);
    animation = Tween<double>(begin: progress - 1, end: progress * 1.0)
        .animate(curve);

    animation.addListener(() {
      setState(() {
        animationProgress = animation.value / total;
      });
    });

    animation.addStatusListener((status) {
      if (animation.isCompleted) {
        bAnimating = false;
        controller.reset();
      }
    });

    controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    animation.removeListener(() { });
    animation.removeStatusListener((status) { });
  }

  @override
  void initState() {
    super.initState();
    progress = widget.progress;
    total = widget.total;

    controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

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
                /*child: LinearPercentIndicator(
                  animation: true,
                  lineHeight: 20.0,
                  animationDuration: 1000,
                  percent: progress/total,
                  barRadius: const Radius.circular(45),
                  progressColor: Theme.of(context).primaryColor,
                  curve: Curves.easeOutSine,
                  backgroundColor: Colors.white,
                ),*/
                child: LinearProgressIndicator(
                  value: bAnimating ? animationProgress : progress/total,
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(45),
                  minHeight: 20.0,

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
