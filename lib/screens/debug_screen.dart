import 'package:flutter/material.dart';
import 'package:vocabella/managers/double_backup.dart';
import 'package:vocabella/models/removed_subject_model.dart';

import '../models/subject_data_model.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {

  String dataInfo = "";
  String binInfo = "";
  String backup1 = "";
  String backup2 = "";
  String backup3 = "";

  @override
  void initState() {
    dataInfo = SubjectDataModel.listToJson(SubjectDataModel.subjectList);
    binInfo = SubjectDataModel.listToJson(RemovedSubjectModel.recycleBin);
    DoubleBackup.loadDBCount().then((value) {
      setState(() {
        backup1 = value!;
      });
    });
    DoubleBackup.loadDoubleBackup(DoubleBackup.dbFirstSpec).then((value) {
      setState(() {
        backup2 = value!;
      });
    });
    DoubleBackup.loadDoubleBackup(DoubleBackup.dbSecondSpec).then((value) {
      setState(() {
        backup3 = value!;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Debug screen"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(width: double.infinity, child: Text(dataInfo)),
            Divider(),
            Container(width: double.infinity, child: Text(binInfo)),
            Divider(),
            Container(width: double.infinity, child: Text(backup1)),
            Divider(),
            Container(width: double.infinity, child: Text(backup2)),
            Divider(),
            Container(width: double.infinity, child: Text(backup3)),
          ],
        ),
      ),
    );
  }
}
