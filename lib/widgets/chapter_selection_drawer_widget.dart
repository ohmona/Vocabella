import 'package:flutter/material.dart';
import 'package:vocabella/models/subject_data_model.dart';

class ChapterSelectionDrawer extends StatelessWidget {
  const ChapterSelectionDrawer(
      {Key? key,
      required this.subjectData,
      required this.changeChapter,
      required this.getChapterName,
      required this.currentChapterIndex, required this.addChapter})
      : super(key: key);

  final SubjectDataModel subjectData;
  final void Function(String) changeChapter;
  final String Function(int) getChapterName;
  final int currentChapterIndex;
  final void Function(String) addChapter;

  static TextEditingController controller = TextEditingController();
  static String newTitle = "";

  Future<void> openChapterTitleEditor(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Type the title of the new chapter"),
          content: TextField(
            controller: controller,
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("cancel"),
            ),
            TextButton(
              onPressed: () {
                if(controller.text.isNotEmpty) {
                  addChapter(controller.text);
                  controller.text = "";
                  Navigator.of(context).pop();
                }
              },
              child: const Text("confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Text(
              subjectData.title!,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("Add chapter"),
              IconButton(
                onPressed: () {
                  openChapterTitleEditor(context);
                },
                icon: const Icon(Icons.add),
                splashRadius: 0.1,
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          Container(
            color: Colors.grey,
            height: 1,
          ),
          Expanded(
            child: ListView.separated(
              itemCount: subjectData.wordlist!.length,
              separatorBuilder: (context, index) {
                return Container(
                  color: Colors.grey,
                  height: 1,
                );
              },
              itemBuilder: (context, index) {
                return GridTile(
                  child: GestureDetector(
                    onTap: () {
                      changeChapter(getChapterName(index));
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(15),
                          child: Text(
                            subjectData.wordlist![index].name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        (currentChapterIndex == index)
                            ? const Icon(Icons.arrow_left)
                            : Container(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
