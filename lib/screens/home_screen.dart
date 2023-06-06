import 'package:flutter/material.dart';
import 'package:vocabella/arguments.dart';
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
      body: ListView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(10),
        children: [
          for (int i = 0; i < 100; i++)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ChapterSelectionScreen.routeName,
                  arguments: ChapterSelectionScreenArguments(
                    SubjectDataModel.createExampleData(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(1),
                child: Row(
                  children: const [
                    Icon(Icons.image),
                    SizedBox(width: 20),
                    Text("Subject name"),
                    SizedBox(width: 20),
                    Text("Subjects"),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
