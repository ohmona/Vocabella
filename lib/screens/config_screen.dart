import 'package:flutter/material.dart';
import 'package:vocabella/configuration.dart';

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

  TextEditingController intervalInput = TextEditingController();

  @override
  void initState() {
    super.initState();

    AppConfig.load();
    bDebugMode = AppConfig.bDebugMode;
    bUseSmartWordOrder = AppConfig.bUseSmartWordOrder;
    checkCreationDateWhileMerging = AppConfig.checkCreationDateWhileMerging;
    checkExamplesWhileMerging = AppConfig.checkExamplesWhileMerging;
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
                        if(newInterval >= 10 && newInterval < 500) {
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
                      AppConfig.checkCreationDateWhileMerging = checkCreationDateWhileMerging;
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
                      AppConfig.checkExamplesWhileMerging = checkExamplesWhileMerging;
                      AppConfig.save();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
