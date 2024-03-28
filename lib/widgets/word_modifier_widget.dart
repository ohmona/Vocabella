import 'package:flutter/material.dart';
import 'package:vocabella/models/wordpair_model.dart';
import 'package:vocabella/utils/modal.dart';

import '../utils/constants.dart';

enum SelectMode {
  range,
  date,
}

class WordModifier extends StatefulWidget {
  const WordModifier({
    Key? key,
    required this.excludedIndex,
    required this.applyEdit,
    required this.size,
    required this.list,
  }) : super(key: key);

  final List<WordPair> list;
  final List<int> excludedIndex;
  final void Function(List<int>) applyEdit;
  final int size;

  @override
  State<WordModifier> createState() => _WordModifierState();
}

class _WordModifierState extends State<WordModifier> {
  late List<int> excludedIndex;
  late SelectMode mode;

  TextEditingController rangeStartPos = TextEditingController();
  bool rangeStartPosValue = false;
  TextEditingController rangeEndPos = TextEditingController();
  bool rangeEndPosValue = false;
  TextEditingController rangeSize = TextEditingController();
  bool rangeSizeValue = false;

  TextEditingController dateSize = TextEditingController();
  bool dateSizeValue = false;

  bool rangeSelect = true;

  bool rangeValidity() {
    if (rangeStartPosValue && rangeEndPosValue && rangeSizeValue) {
      return false;
    }
    return true;
  }

  void rangeApply() {
    num? rsp = num.tryParse(rangeStartPos.text);
    num? rep = num.tryParse(rangeEndPos.text);
    num? rs = num.tryParse(rangeSize.text);
    if (rangeStartPosValue && rangeSizeValue) {
      if (rsp != null && rs != null) {
        if (rsp > 0 && rs > 0) {
          for (int i = rsp.toInt() - 1;
              i < (rsp.toInt() - 1) + rs.toInt();
              i++) {
            rangeSelect ? select(i) : deselect(i);
          }
          return;
        }
      }
    } else if (rangeEndPosValue && rangeSizeValue) {
      if (rep != null && rs != null) {
        if (rep > 0 && rs > 0) {
          for (int i = rep.toInt() - 1; i >= rep.toInt() - rs.toInt(); i--) {
            rangeSelect ? select(i) : deselect(i);
          }
          return;
        }
      }
    } else if (rangeEndPosValue && rangeStartPosValue) {
      if (rep != null && rsp != null) {
        if (rsp > 0 && rep > 0) {
          for (int i = rsp.toInt() - 1; i <= rep.toInt() - 1; i++) {
            rangeSelect ? select(i) : deselect(i);
          }
          return;
        }
      }
    }
    Future.delayed(const Duration(milliseconds: 10), () {
      openAlert(context, title: "Warning", content: "Invalid Input");
    });
  }

  void select(int index) {
    setState(() {
      if (excludedIndex.contains(index)) {
        excludedIndex.remove(index);
      }
    });
  }

  void deselect(int index) {
    setState(() {
      if (!excludedIndex.contains(index)) {
        excludedIndex.add(index);
      }
    });
  }

  List<int> oldestLearned(int size) {
    List<WordPair> list = [];
    List<DateTime> dates = [];
    for (var v in widget.list) {
      if (!dates.contains(v.lastLearned)) {
        dates.add(v.lastLearned!);
      }
    }
    dates.sort();
    for (var d in dates) {
      for (var v in widget.list) {
        if (d == v.lastLearned) {
          list.add(v);
        }
      }
    }

    List<int> ind = [];
    for (int i = 0; i < size; i++) {
      ind.add(widget.list.indexOf(list[i]));
    }
    return ind;
  }

  List<int> oldestLearnedOnly() {
    List<WordPair> list = [];
    List<DateTime> dates = [];
    for (var v in widget.list) {
      if (!dates.contains(v.lastLearned)) {
        dates.add(v.lastLearned!);
      }
    }
    dates.sort();
    for (var v in widget.list) {
      if (dates[0] == v.lastLearned) {
        list.add(v);
      }
    }

    List<int> ind = [];
    for (int i = 0; i < list.length; i++) {
      ind.add(widget.list.indexOf(list[i]));
    }
    return ind;
  }

  List<int> recentlyLearned(int size) {
    List<WordPair> list = [];
    List<DateTime> dates = [];
    for (var v in widget.list) {
      if (!dates.contains(v.lastLearned)) {
        dates.add(v.lastLearned!);
      }
    }
    dates.sort();
    for (var d in dates.reversed) {
      for (var v in widget.list) {
        if (d == v.lastLearned) {
          list.add(v);
        }
      }
    }

    List<int> ind = [];
    for (int i = 0; i < size; i++) {
      ind.add(widget.list.indexOf(list[i]));
    }
    return ind;
  }

  List<int> recentlyLearnedOnly() {
    List<WordPair> list = [];
    List<DateTime> dates = [];
    for (var v in widget.list) {
      if (!dates.contains(v.lastLearned)) {
        dates.add(v.lastLearned!);
      }
    }
    dates.sort();
    for (var v in widget.list) {
      if (dates.reversed.first == v.lastLearned) {
        list.add(v);
      }
    }

    List<int> ind = [];
    for (int i = 0; i < list.length; i++) {
      ind.add(widget.list.indexOf(list[i]));
    }
    return ind;
  }

  List<int> notLearned() {
    List<WordPair> list = [];
    for (var v in widget.list) {
      if (v.lastLearned == null) {
        list.add(v);
      } else if (v.lastLearned == DateTime(1, 1, 1, 0, 0)) {
        list.add(v);
      }
    }

    List<int> ind = [];
    for (int i = 0; i < list.length; i++) {
      ind.add(widget.list.indexOf(list[i]));
    }
    return ind;
  }

  @override
  void initState() {
    super.initState();
    excludedIndex = widget.excludedIndex;
    mode = SelectMode.range;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Modify Word Selection"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      mode = SelectMode.range;
                    });
                  },
                  child: const Text("Range")),
              TextButton(
                  onPressed: () {
                    setState(() {
                      mode = SelectMode.date;
                    });
                  },
                  child: const Text("Date")),
            ],
          ),
          const Divider(),
          if (mode == SelectMode.range)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      rangeStartPos.text = 1.toString();
                    });
                  },
                  child: const Text(
                    "Start",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Checkbox(
                  value: rangeStartPosValue,
                  onChanged: (value) {
                    setState(() {
                      rangeStartPosValue = value!;

                      if (!rangeValidity()) {
                        rangeStartPosValue = !value;
                      }
                    });
                  },
                ),
                Flexible(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    enabled: rangeStartPosValue,
                    controller: rangeStartPos,
                  ),
                ),
              ],
            ),
          if (mode == SelectMode.range)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      rangeEndPos.text = widget.size.toString();
                    });
                  },
                  child: const Text(
                    "Last",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Checkbox(
                  value: rangeEndPosValue,
                  onChanged: (value) {
                    setState(() {
                      rangeEndPosValue = value!;

                      if (!rangeValidity()) {
                        rangeEndPosValue = !value;
                      }
                    });
                  },
                ),
                Flexible(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    enabled: rangeEndPosValue,
                    controller: rangeEndPos,
                  ),
                ),
              ],
            ),
          if (mode == SelectMode.range)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (rangeSizeValue) {
                        if (rangeEndPos.text.isNotEmpty && rangeEndPosValue) {
                          rangeSize.text = rangeEndPos.text;
                        }
                        if (rangeStartPos.text.isNotEmpty &&
                            rangeStartPosValue) {
                          num? n = num.tryParse(rangeStartPos.text);
                          if (n != null) {
                            rangeSize.text = (widget.size - n + 1).toString();
                          }
                        }
                      }
                    });
                  },
                  child: const Text(
                    "Length",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Checkbox(
                  value: rangeSizeValue,
                  onChanged: (value) {
                    setState(() {
                      rangeSizeValue = value!;

                      if (!rangeValidity()) {
                        rangeSizeValue = !value;
                      }
                    });
                  },
                ),
                Flexible(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    enabled: rangeSizeValue,
                    controller: rangeSize,
                  ),
                ),
              ],
            ),
          if (mode == SelectMode.range)
            const SizedBox(
              height: 10,
            ),
          if (mode == SelectMode.range)
            Row(
              children: [
                const Text("Select/Deselect"),
                Checkbox(
                  value: rangeSelect,
                  onChanged: (value) {
                    setState(() {
                      rangeSelect = value!;
                    });
                  },
                ),
              ],
            ),
          if (mode == SelectMode.date)
            const SizedBox(
              height: 10,
            ),
          if (mode == SelectMode.date)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var i in notLearned()) {
                    select(i);
                  }
                });
              },
              child: const Text(
                "Select Not Learned",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          if (mode == SelectMode.date)
            const SizedBox(
              height: 10,
            ),
          if (mode == SelectMode.date)
            TextButton(
              onPressed: () {
                setState(() {
                  num? n = num.tryParse(dateSize.text);
                  if (n != null && n > 0 && n <= widget.size) {
                    for (var i in oldestLearned(n.toInt())) {
                      select(i);
                    }
                  }
                });
              },
              child: const Text(
                "Select Oldest Learned",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          if (mode == SelectMode.date)
            const SizedBox(
              height: 10,
            ),
          if (mode == SelectMode.date)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var i in oldestLearnedOnly()) {
                    select(i);
                  }
                });
              },
              child: const Text(
                "Select Solely Oldest Learned",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          if (mode == SelectMode.date)
            const SizedBox(
              height: 10,
            ),
          if (mode == SelectMode.date)
            TextButton(
              onPressed: () {
                setState(() {
                  num? n = num.tryParse(dateSize.text);
                  if (n != null && n > 0 && n <= widget.size) {
                    for (var i in recentlyLearned(n.toInt())) {
                      select(i);
                    }
                  }
                });
              },
              child: const Text(
                "Select Most Recently Learned",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          if (mode == SelectMode.date)
            const SizedBox(
              height: 10,
            ),
          if (mode == SelectMode.date)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var i in recentlyLearnedOnly()) {
                    select(i);
                  }
                });
              },
              child: const Text(
                "Select Solely Recently Learned",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          if (mode == SelectMode.date)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      dateSize.text = widget.size.toString();
                    });
                  },
                  child: const Text(
                    "Size",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Checkbox(
                  value: dateSizeValue,
                  onChanged: (value) {
                    setState(() {
                      dateSizeValue = value!;
                    });
                  },
                ),
                Flexible(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    enabled: dateSizeValue,
                    controller: dateSize,
                  ),
                ),
              ],
            ),
        ],
      ),
      actions: <Widget>[
        Text("selected: ${widget.size - excludedIndex.length}"),
        TextButton(
          onPressed: () {
            if (mode == SelectMode.range) {
              rangeApply();
              widget.applyEdit(excludedIndex);
            } else if (mode == SelectMode.date) {
              widget.applyEdit(excludedIndex);
            }
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: mintColor,
          ),
          child: const Text("apply"),
        ),
      ],
    );
  }
}
