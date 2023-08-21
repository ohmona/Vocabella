import 'package:flutter/material.dart';
import 'package:vocabella/constants.dart';
import 'package:vocabella/models/subject_data_model.dart';

class LanguageBar extends StatelessWidget {
  const LanguageBar(
      {Key? key,
      required this.subjectData,
      required this.index,
      required this.changeSubject})
      : super(key: key);

  final SubjectDataModel subjectData;
  final int index;
  final void Function({
    required String newSubject,
    required String newLanguage,
    required int index,
  }) changeSubject;

  Future<void> openLanguageEditor(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return SubjectChangeDialog(
          subject: subjectData.subjects![index],
          language: subjectData.languages![index],
          changeSubject: changeSubject,
          index: index,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () {
          openLanguageEditor(context);
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFCBCBCB),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
            boxShadow: [
              BoxShadow(
                color: Color(0x6ECBCBCB),
                offset: Offset(0, 3),
                blurRadius: 10,
              ),
            ],
          ),
          height: 50,
          alignment: Alignment.center,
          child: Text(
            subjectData.subjects![index],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class SubjectChangeDialog extends StatefulWidget {
  const SubjectChangeDialog(
      {Key? key,
      required this.subject,
      required this.language,
      required this.changeSubject,
      required this.index})
      : super(key: key);

  final String subject;
  final String language;
  final int index;
  final void Function({
    required String newSubject,
    required String newLanguage,
    required int index,
  }) changeSubject;

  @override
  State<SubjectChangeDialog> createState() => _SubjectChangeDialogState();
}

class _SubjectChangeDialogState extends State<SubjectChangeDialog> {
  TextEditingController controller = TextEditingController();
  late String subjectText;
  late String languageText;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    controller.text = widget.subject;

    subjectText = widget.subject;
    languageText = widget.language;
  }

  @override
  Widget build(BuildContext context) {
    focusNode.requestFocus();
    return AlertDialog(
      title: const Text("Type new subject name"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              focusNode: focusNode,
              maxLength: 20,
              controller: controller,
              onChanged: (value) {
                subjectText = value;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "language : [$languageText]",
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.language),
                  initialValue: languageText,
                  itemBuilder: (context) {
                    return [
                      for (String str in languageList)
                        PopupMenuItem(
                          value: str,
                          child: Text(str),
                        )
                    ];
                  },
                  onSelected: (value) {
                    setState(() {
                      languageText = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: mintColor,
          ),
          child: const Text("cancel"),
        ),
        TextButton(
          onPressed: () {
            widget.changeSubject(
              index: widget.index,
              newLanguage: languageText,
              newSubject: subjectText,
            );
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: mintColor,
          ),
          child: const Text("confirm"),
        ),
      ],
    );
  }
}
