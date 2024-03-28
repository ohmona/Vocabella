import 'package:flutter/material.dart';
import 'package:googleapis/analyticsreporting/v4.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vocabella/managers/event_data_file.dart';
import 'package:vocabella/models/event_data_model.dart';
import 'package:vocabella/screens/mode_selection_screen.dart';
import 'package:vocabella/utils/arguments.dart';
import 'package:vocabella/utils/chrono.dart';
import 'package:vocabella/utils/constants.dart';
import 'package:vocabella/utils/modal.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  static const routeName = '/planner';

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

typedef Event = Map<DateTime, List<String>>;

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<EventDataModel> _getEventsForDay(DateTime day) {
    List<EventDataModel> list = [];
    for (var element in EventDataModel.eventList) {
      if (areTheSameDay(day, element.date)) {
        list.add(element);
      }
    }
    return list;
  }

  void onPressPlay(EventDataModel event) {
    if (event.bValid) {
      Navigator.pushNamed(
        context,
        ModeSelectionScreenParent.routeName,
        arguments: ModeSelectionScreenArguments(
          event.wordPack!,
          [],
          event.subjectData!,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    EventDataFile.readData().then((value) {
      EventDataFile.applyJson(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planner"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(DateTime.now().year, 1, 1),
            lastDay: DateTime.utc(DateTime.now().year + 2, 12, 31),
            focusedDay: DateTime.now(),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` here as well
                print(_selectedDay);
                print(_focusedDay);
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            pageJumpingEnabled: false,
            eventLoader: (day) {
              return _getEventsForDay(day);
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(_selectedDay).length,
              itemBuilder: (context, index) {
                var event = _getEventsForDay(_selectedDay)[index];
                return Container(
                  height: 60,
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: mintColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (areTheSameDay(_selectedDay, DateTime.now()))
                            Checkbox(
                              value: event.bPractised,
                              onChanged: (value) {
                                setState(() {
                                  _getEventsForDay(_selectedDay)[index]
                                      .bPractised = value;
                                  EventDataFile.saveData();
                                });
                              },
                              checkColor: Colors.white,
                              activeColor: Colors.green,
                            ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            event.title!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (isPastDay(_focusedDay, DateTime.now()) &&
                              event.bPractised == true)
                            const Icon(Icons.check),
                          if (isPastDay(_focusedDay, DateTime.now()) &&
                              event.bPractised == false)
                            const Icon(Icons.dangerous_outlined),
                        ],
                      ),
                      Text(
                        "words: ${event.size}",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      Row(
                        children: [
                          if (isFutureDay(_selectedDay, DateTime.now()) ||
                              event.bPractised!)
                            IconButton(
                                onPressed: () {
                                  openConfirm(
                                    context,
                                    title: "Warning!",
                                    content:
                                        "Are you sure you want to delete this plan?",
                                    onConfirm: () => setState(() {
                                      EventDataModel.eventList.removeAt(
                                          EventDataModel.eventList
                                              .indexOf(event));
                                      EventDataFile.saveData();
                                    }),
                                  );
                                },
                                icon: const Icon(Icons.delete)),
                          if (areTheSameDay(_selectedDay, DateTime.now()))
                            IconButton(
                                onPressed: () {
                                  onPressPlay(event);
                                },
                                icon: const Icon(Icons.play_arrow)),
                        ],
                      ),
                    ],
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
