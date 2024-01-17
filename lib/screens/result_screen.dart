import 'dart:io';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:vocabella/overlays/loading_scene_overlay.dart';
import 'package:vocabella/utils/arguments.dart';
import 'package:vocabella/utils/constants.dart';
import 'package:vocabella/managers/subject_data_manipulator.dart';
import 'package:vocabella/widgets/bottom_bar_widget.dart';

import '../managers/data_handle_manager.dart';
import '../managers/double_backup.dart';
import '../models/subject_data_model.dart';
import '../utils/chrono.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  static const routeName = '/result';

  String makeCheeringText(double inFirstTry) {
    if (inFirstTry == 1) {
      return "Glorious!!!";
    } else if (inFirstTry > 0.9) {
      return "Excellent!!";
    } else if (inFirstTry > 0.8) {
      return "Great job!!";
    } else if (inFirstTry > 0.75) {
      return "Well done!";
    } else if (inFirstTry > 0.50) {
      return "Keep going!";
    } else if (inFirstTry > 0.3) {
      return "Practise more :)";
    } else {
      return "Training finished";
    }
  }

  Future<File?> saveData() async {
    await DataReadWriteManager.writeData(
        SubjectDataModel.listToJson(SubjectDataModel.subjectList));
    await DoubleBackup.toggleDBCount();
    var future = DoubleBackup.saveDoubleBackup(
        SubjectDataModel.listToJson(SubjectDataModel.subjectList));
    return future;
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ResultScreenArguments;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                firstBgColor.withOpacity(0.7),
                secondBgColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      makeCheeringText(args.inFirstTry),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 15,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 300,
                          width: 300,
                          child: CircularPercentIndicator(
                            animationDuration: 1000,
                            animation: true,
                            backgroundWidth: 30,
                            lineWidth: 30,
                            radius: 150,
                            linearGradient: bgGradient,
                            backgroundColor: Colors.white.withOpacity(0.5),
                            circularStrokeCap: CircularStrokeCap.round,
                            percent: args.inFirstTry,
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                child: Text(
                                  "Learned ${args.total} words",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white,
                                        blurRadius: 15,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 150,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              Text(
                                "Answered ${(args.inFirstTry * 100).toInt()}% \n of words in first try",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white,
                                      blurRadius: 15,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "time lasted: ${formatLastedTime(calcLastedTime(args.startTime, DateTime.now()))}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 15,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  Navigator.of(context).push(LoadingOverlay());
                  // Conduct operations
                  for (var operation in args.operations) {
                    SubjectManipulator.operate(str: operation);
                  }
                  // Return to home
                  await saveData();
                  Future.delayed(const Duration(milliseconds: 10), () {
                    SubjectManipulator.disposeAccess();
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  });
                },
                child: const ContinueButton(
                  correctState: CorrectState.correct,
                  color: Colors.green,
                  text: "return to main menu",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
