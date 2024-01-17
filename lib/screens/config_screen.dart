import 'package:flutter/material.dart';
import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/utils/configuration.dart';

import '../managers/data_handle_manager.dart';
import '../managers/double_backup.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  static const routeName = '/config';

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late bool bDebugMode;
  late bool bUseSmartWordOrder;
  late bool checkCreationDateWhileMerging;
  late bool checkExamplesWhileMerging;
  late bool stopTTSBeforeContinuing;

  TextEditingController intervalInput = TextEditingController();

  @override
  void initState() {
    super.initState();

    AppConfig.load();
    bDebugMode = AppConfig.bDebugMode;
    bUseSmartWordOrder = AppConfig.bUseSmartWordOrder;
    checkCreationDateWhileMerging = AppConfig.checkCreationDateWhileMerging;
    checkExamplesWhileMerging = AppConfig.checkExamplesWhileMerging;
    stopTTSBeforeContinuing = AppConfig.stopTTSBeforeContinuing;
    intervalInput.text = AppConfig.quizTimeInterval.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuration"),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Debug mode"),
                Checkbox(
                  value: bDebugMode,
                  onChanged: (bool? value) {
                    setState(() {
                      bDebugMode = value!;
                      AppConfig.bDebugMode = bDebugMode;
                      AppConfig.save();
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Time interval between questions (10ms ~ 500ms)"),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: intervalInput,
                    keyboardType: const TextInputType.numberWithOptions(),
                    textAlign: TextAlign.center,
                    onSubmitted: (value) {
                      setState(() {
                        var newInterval = int.parse(value);
                        if (newInterval >= 10 && newInterval < 500) {
                          AppConfig.quizTimeInterval = newInterval;
                          AppConfig.save();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Use smart question system"),
                Checkbox(
                  value: bUseSmartWordOrder,
                  onChanged: (bool? value) {
                    setState(() {
                      bUseSmartWordOrder = value!;
                      AppConfig.bUseSmartWordOrder = bUseSmartWordOrder;
                      AppConfig.save();
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Check creation date while importing"),
                Checkbox(
                  value: checkCreationDateWhileMerging,
                  onChanged: (bool? value) {
                    setState(() {
                      checkCreationDateWhileMerging = value!;
                      AppConfig.checkCreationDateWhileMerging =
                          checkCreationDateWhileMerging;
                      AppConfig.save();
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Check examples while importing"),
                Checkbox(
                  value: checkExamplesWhileMerging,
                  onChanged: (bool? value) {
                    setState(() {
                      checkExamplesWhileMerging = value!;
                      AppConfig.checkExamplesWhileMerging =
                          checkExamplesWhileMerging;
                      AppConfig.save();
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Stop TTS before continuing"),
                Checkbox(
                  value: stopTTSBeforeContinuing,
                  onChanged: (bool? value) {
                    setState(() {
                      stopTTSBeforeContinuing = value!;
                      AppConfig.stopTTSBeforeContinuing =
                          stopTTSBeforeContinuing;
                      AppConfig.save();
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Fix invalid"),
                TextButton(
                  onPressed: () async {
                    SubjectDataModel.fixInvalid();

                    print("Writing data...");
                    // Finally we have to save data to the local no matter it should be
                    await DataReadWriteManager.writeData(
                        SubjectDataModel.listToJson(SubjectDataModel.subjectList)); // FUTURE

                    print("toggle db count...");
                    // After that we need to create another backup for fatal case like loosing data
                    // Firstly, we toggle the count
                    await DoubleBackup.toggleDBCount(); // FUTURE

                    print("save double backup...");
                    // Then save the backup data
                    var future = DoubleBackup.saveDoubleBackup(
                        SubjectDataModel.listToJson(SubjectDataModel.subjectList)); // FUTURE
                  },
                  child: const Text("fix"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
