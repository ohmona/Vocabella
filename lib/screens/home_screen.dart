
import 'package:flutter/material.dart';
import 'package:vocabella/arguments.dart';
import 'package:vocabella/managers/data_handle_manager.dart';
import 'package:vocabella/screens/chapter_selection_screen.dart';

import '../models/subject_data_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vocabella"),
      ),
      body: const SubjectList(),
    );
  }
}

class SubjectList extends StatefulWidget {
  const SubjectList({Key? key}) : super(key: key);

  @override
  State<SubjectList> createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectList> {
  void loadNewData() {
    DataPickerManager.pickFile().then((result) {
      if (result != null) {
        DataReadWriteManager.readDataByPath(result.files.single.path!)
            .then((value) {
          print('===================================================');

          SubjectDataModel.addAll(SubjectDataModel.listFromJson(value));
          SubjectDataModel.printEveryData();

          refreshData();

          print("Length : ${SubjectDataModel.subjectList.length}");

          DataReadWriteManager.writeData(
              SubjectDataModel.listToJson(SubjectDataModel.subjectList));
        });
      }
    });
  }

  void refreshData() {
    DataReadWriteManager.readData().then((value) {
      try {
        if (value.isNotEmpty) {
          print('===================================================');
          print("REFRESH");

          SubjectDataModel.subjectList = SubjectDataModel.listFromJson(value);
          SubjectDataModel.printEveryData();

          print("Length : ${SubjectDataModel.subjectList.length}");
        }
      } catch (e) {
        if(e is FormatException) {
          print('You can only import files with extension ".json"');
        }
      }
      setState(() {});
    });
  }

  void reset() {
    // Clear the subjectList before adding new data
    SubjectDataModel.subjectList.clear();
    setState(() {});
    DataReadWriteManager.writeData("");
  }

  @override
  void initState() {
    // Load datas
    DataReadWriteManager.readData().then((value) {
      if (value.isNotEmpty) {
        print("==========================================");
        print("REFRESH");
        refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("==========================================");
    print("THE LIST");
    print("${SubjectDataModel.subjectList}");
    print("==========================================");

    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        Column(
          children: [
            ElevatedButton(
              onPressed: loadNewData,
              child: const Icon(Icons.add),
            ),
            ElevatedButton(
              onPressed: refreshData,
              child: const Icon(Icons.refresh),
            ),
            ElevatedButton(
              onPressed: reset,
              child: const Icon(Icons.delete),
            ),
          ],
        ),
        for (SubjectDataModel subject in SubjectDataModel.subjectList)
          SubjectTile(subject: subject),
      ],
    );
  }
}

class SubjectTile extends StatelessWidget {
  const SubjectTile({Key? key, required this.subject}) : super(key: key);

  final SubjectDataModel subject;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          ChapterSelectionScreen.routeName,
          arguments: ChapterSelectionScreenArguments(
            subject,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(1),
        child: Row(
          children: [
            const Icon(Icons.image),
            const SizedBox(width: 20),
            Text(subject.title!),
            const SizedBox(width: 20),
            Text(subject.subjects![0]),
            const Text(" // "),
            Text(subject.subjects![1]),
          ],
        ),
      ),
    );
  }
}
