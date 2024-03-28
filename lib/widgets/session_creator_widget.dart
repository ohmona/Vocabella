import 'package:flutter/material.dart';
import 'package:vocabella/managers/event_data_file.dart';
import 'package:vocabella/models/subject_data_model.dart';

import '../models/event_data_model.dart';
import '../models/wordpair_model.dart';
import '../utils/chrono.dart';
import '../utils/constants.dart';

class SessionCreator extends StatefulWidget {
  const SessionCreator(
      {Key? key, required this.wordPack, required this.subjectData})
      : super(key: key);

  final List<WordPair> wordPack;
  final SubjectDataModel subjectData;

  @override
  State<SessionCreator> createState() => _SessionCreatorState();
}

class _SessionCreatorState extends State<SessionCreator> {
  DateTime date = DateTime.now();
  String title = "New Plan";

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller.text = title;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New Plan"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Date: ${formatDay(date)}"),
              IconButton(
                onPressed: () async {
                  showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime.utc(DateTime
                        .now()
                        .year, 1, 1),
                    lastDate: DateTime.utc(DateTime
                        .now()
                        .year + 2, 12, 31),
                  ).then((value) {
                    setState(() {
                      date = value ?? DateTime.now();
                    });
                  });
                },
                icon: Icon(Icons.calendar_month),
              ),
            ],
          ),
          Row(
            children: [
              Text("Title: "),
              SizedBox(width: 10),
              Flexible(
                child: TextField(
                  controller: controller,
                  onChanged: (value) {
                    setState(() {
                      controller.text = value;
                      title = value;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      controller.text = value;
                      title = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
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
            if(!isPastDay(date, DateTime.now())) {
              EventDataModel event = EventDataModel(
                date: date,
                title: title,
                subjectData: widget.subjectData,
                wordPack: widget.wordPack,
              );
              EventDataModel.eventList.add(event);
              EventDataFile.saveData();
              Future.delayed(const Duration(milliseconds: 10), () {
                Navigator.popUntil(context, (route) {
                  return route.isFirst;
                });
              });
            }
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
