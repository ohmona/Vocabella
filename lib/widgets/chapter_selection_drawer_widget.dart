import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vocabella/utils/configuration.dart';
import 'package:vocabella/utils/constants.dart';
import 'package:vocabella/managers/data_handle_manager.dart';
import 'package:vocabella/models/subject_data_model.dart';
import 'package:vocabella/utils/modal.dart';
import 'package:vocabella/utils/widget_calculation.dart';

import '../models/chapter_model.dart';

class ChapterSelectionDrawer extends StatefulWidget {
  const ChapterSelectionDrawer({
    Key? key,
    required this.subjectData,
    required this.changeChapter,
    required this.getCurrentChapterPath,
    required this.addChapter,
    required this.saveData,
    required this.changeThumbnail,
    required this.changeSubjectName,
    required this.reorderChapter,
    required this.existChapterNameAlready,
    required this.openDoubleChecker,
    required this.duplicateChapter,
    required this.showLoadingScreen,
    required this.addFolder,
    required this.moveChapter,
    required this.addVisibleList,
    required this.removeVisibleList,
    required this.visibleList,
    required this.insertChapters,
  }) : super(key: key);

  final SubjectDataModel subjectData; // Sorted!!
  final void Function(String) changeChapter;
  final bool Function(String) addChapter;
  final String Function() getCurrentChapterPath;
  final void Function() saveData;
  final void Function(String) changeThumbnail;
  final void Function(String) changeSubjectName;
  final void Function(String, int) reorderChapter;
  final void Function(BuildContext) openDoubleChecker;
  final bool Function(String) existChapterNameAlready;
  final void Function() duplicateChapter;
  final void Function(BuildContext) showLoadingScreen;
  final void Function(String) addFolder;
  final void Function(String, String) moveChapter;
  final void Function(String) addVisibleList;
  final void Function(String) removeVisibleList;
  final void Function(int, int, int) insertChapters;
  final List<String> visibleList;

  static TextEditingController controller = TextEditingController();
  static String newTitle = "";

  @override
  State<ChapterSelectionDrawer> createState() => ChapterSelectionDrawerState();
}

class ChapterSelectionDrawerState extends State<ChapterSelectionDrawer> {
  Image? _loadedImage; // New variable to hold the loaded image

  GlobalKey listViewKey = GlobalKey();

  late ScrollController controller;
  late int selectedIndex;
  late int hoveringIndex;
  late int gapIndex;

  late bool bScrolling;

  late List<Chapter> chapterList;

  //late List<String> visibleList;
  late List<String> pathList;

  Future<void> openChapterTitleEditor(BuildContext context) {
    ChapterSelectionDrawer.controller.text = "";
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Type the title of the new chapter"),
          content: TextField(
            controller: ChapterSelectionDrawer.controller,
            autofocus: true,
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
                setState(() {
                  if (ChapterSelectionDrawer.controller.text.isNotEmpty) {
                    if (widget
                        .addChapter(ChapterSelectionDrawer.controller.text)) {
                      ChapterSelectionDrawer.controller.text = "";
                      Future.delayed(const Duration(milliseconds: 1), () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      });
                    } else {
                      ChapterSelectionDrawer.controller.text = "";
                      Navigator.of(context).pop();
                      openAlert(context,
                          title: "Warning",
                          content:
                              "You can't create a chapter with an existing name");
                    }
                  }
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: mintColor,
              ),
              child: const Text("confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> openSubjectNameEditor(BuildContext context) {
    ChapterSelectionDrawer.controller.text = widget.subjectData.title;
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Type the new title of the project"),
          content: TextField(
            controller: ChapterSelectionDrawer.controller,
            autofocus: true,
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
                if (ChapterSelectionDrawer.controller.text.isNotEmpty) {
                  widget.changeSubjectName(
                      ChapterSelectionDrawer.controller.text);
                  ChapterSelectionDrawer.controller.text = "";
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: mintColor,
              ),
              child: const Text("confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> openFolderAdder(BuildContext context) {
    ChapterSelectionDrawer.controller.text = "";
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Type the title of the new folder"),
          content: TextField(
            controller: ChapterSelectionDrawer.controller,
            autofocus: true,
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
                if (ChapterSelectionDrawer.controller.text.isNotEmpty) {
                  widget.addFolder(ChapterSelectionDrawer.controller.text);
                  ChapterSelectionDrawer.controller.text = "";
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: mintColor,
              ),
              child: const Text("confirm"),
            ),
          ],
        );
      },
    );
  }

  void loadImage() {
    const Image dummyImage = Image(
      image: AssetImage('assets/400x400.jpg'),
      width: 300,
    );

    File? image;
    if (_loadedImage != null) return;
    if (widget.subjectData.thumb == null) {
      _loadedImage = dummyImage;
      return;
    }

    DataReadWriteManager.loadExistingImage(widget.subjectData.thumb!)
        .then((value) {
      image = value;

      if (image != null) {
        setState(() {
          _loadedImage = Image(
            image: FileImage(image!),
            errorBuilder: (context, error, stackTrace) {
              return dummyImage;
            },
          );
        });
      } else {
        _loadedImage = dummyImage;
      }
    });
  }

  void addThumbnail() async {
    File? image = await DataReadWriteManager.loadNewImage(ImageSource.gallery);
    if (image != null) {
      String path = image.path;
      widget.changeThumbnail(path);
      setState(() {
        _loadedImage = Image(
          image: FileImage(image),
        );
      });
    }
  }

  void shareSubject() async {
    String path = await DataReadWriteManager.dirPath;
    File file = File("$path/${widget.subjectData.title}.json");
    await file
        .writeAsString(SubjectDataModel.listToJson([widget.subjectData]))
        .then((value) async {
      DataReadWriteManager.share(
          dir: path, name: "${widget.subjectData.title}.json");
    });
  }

  void requestScroll(
      double destination, double velocity, double current) async {
    if (bScrolling) return;
    bScrolling = true;
    double time = (current - destination).abs() /
        velocity; // velocity (offset per milliseconds)
    await controller.animateTo(destination,
        duration: Duration(milliseconds: time.toInt()), curve: Curves.linear);
    bScrolling = false;
  }

  void stopScroll() {
    if (!bScrolling) return;
    controller.jumpTo(controller.offset);
    bScrolling = false;
  }

  void updateLists(List<Chapter> chapterList) {
    setState(() {
      this.chapterList = chapterList;
      pathList = [];
      for (var chap in chapterList) {
        if (!pathList.contains(chap.path)) {
          pathList.add(chap.path);
        }
      }
      pushDefaultToBehind();
    });
  }

  bool existChapterAt(String path) {
    for (var path in fullElements()) {
      if (path.contains(path)) {
        if (!path.endsWith("/")) {
          return true;
        }
      }
    }
    return false;
  }

  String findParentPath(String str, int depthIndex, int depth) {
    print("parentPath");
    print("parentPath");
    print("parentPath");
    print("parentPath");
    print("0 ${fullElements()}");
    var full = generateFullPath(str, depthIndex, depth);
    print("1 $full");
    full = full.substring(0, full.length - str.length);
    if (!full.startsWith("/")) {
      print("2 /$full");
      return "/$full";
    } else if (!full.endsWith("/")) {
      print("2 $full/");
      return "$full/";
    } else {
      return full;
    }
  }

  // full path only
  String parentPath(String original) {
    //print("parent");
    //print(original);
    var segments = original.split("/");
    //print(segments);
    if (segments.last == "") {
      segments.removeLast();
      segments.removeLast();
    } else {
      segments.removeLast();
    }
    return "${segments.join("/")}/";
  }

  List<Map<String, int>> displayElements() {
    List<String> fullElementsList = fullElements();
    Map<String, int> lastDepthOfSegment = {};
    List<Map<String, int>> resultList = [];

    for (var path in fullElementsList) {
      if (!path.endsWith("/")) {
        var segments = path.split("/")..removeAt(0);

        for (int i = 0; i < segments.length; i++) {
          String segment = segments[i];
          String fullPathSegment = segments.sublist(0, i + 1).join("/");

          if (i < segments.length - 1) {
            segment += "/";
          }

          if (lastDepthOfSegment[fullPathSegment] != i) {
            //print("full path segment: /$fullPathSegment");
            //print("visible list: $visibleList");
            //print("parentPath: /$fullPathSegment");
            if (widget.visibleList.contains(parentPath("/$fullPathSegment"))) {
              resultList.add({segment: i});
              lastDepthOfSegment[fullPathSegment] = i;
            }
          }
        }
      }
    }

    return resultList;
  }

  List<String> fullElements() {
    List<String> elements = [];
    for (int i = 0; i < pathList.length; i++) {
      elements.add(pathList[i]);
      for (var chap in chapterList) {
        if (chap.path == pathList[i]) {
          elements.add(chap.comprisePath());
        }
      }
    }
    return elements;
  }

  int convertToDepthStructureIndex(int pathIndex) {
    throw UnimplementedError();
  }

  String generateFullPath(String str, int depthIndex, int depth) {
    List<String> parents = [];
    int iteration = depth;
    int gap = 1;
    if (depth > 0) {
      while (iteration > 0) {
        if (displayElements()[depthIndex - gap].values.first < iteration &&
            iteration != 0) {
          parents.add(displayElements()[depthIndex - gap].keys.first);
          iteration--;
        }
        gap++;
      }
      parents = parents.reversed.toList();
    }

    String p = "/";
    for (var par in parents) {
      p = "$p$par";
    }
    if (str.startsWith("/")) {
      p = "$p${str.substring(1)}";
    } else {
      p = "$p$str";
    }
    return p;
  }

  int convertToPathStructureIndex(int depthIndex) {
    var path = fullElements();
    final str = "/${displayElements()[depthIndex].keys.first}";
    final depth = displayElements()[depthIndex].values.first;

    for (int i = 0; i < path.length; i++) {
      if (path[i].endsWith(str)) {
        // We found elements ending with the given data
        var p = generateFullPath(str, depthIndex, depth);

        if (p == path[i]) {
          return i;
        }
      }
    }

    // Exception for paths not including str
    var p = generateFullPath(str, depthIndex, depth);
    for (int i = 0; i < path.length; i++) {
      if (path[i].startsWith(p)) {
        if (p == path[i]) {
          return i;
        }
        return i;
      }
    }

    return -1;
  }

  List<String> reducedElements() {
    List<String> reducedPathList = [];
    for (var path in fullElements()) {
      if (!path.endsWith("/")) {
        reducedPathList.add(path);
      }
    }
    return reducedPathList;
  }

  String findElement(int index) {
    return fullElements()[index];
  }

  int pathReducedIndex(int index) {
    String ori;
    if (index < fullElements().length) {
      ori = fullElements()[index];
    } else {
      ori = fullElements()[fullElements().length - 1];
    }
    for (var path in reducedElements()) {
      if (path == ori) {
        return reducedElements().indexOf(path);
      }

      if (fullElements().indexOf(path) > index) {
        return reducedElements().indexOf(path);
      }
    }
    return -1;
  }

  void pushDefaultToBehind() {
    int defaultIndex = pathList.indexOf("/");
    if (defaultIndex != pathList.length - 1) {
      pathList.remove("/");
      pathList.add("/");
    }
  }

  bool isSelected(int index) {
    //...Get Focused Chapter Path/Name
    final focused = widget.getCurrentChapterPath();
    //...Loop through Elements List
    if (fullElements()[convertToPathStructureIndex(index)] == focused) {
      return true;
    }
    return false;
    //...Compare this element and gotten focused Chapter path/name
  }

  int calcSize() {
    int size = 0;
    for (int i = 0; i < pathList.length; i++) {
      size++;
      for (var chap in chapterList) {
        if (chap.path == pathList[i]) {
          size++;
        }
      }
    }
    return size - 1;
  }

  int rootIndex() {
    for (var map in displayElements()) {
      if (map.values.first == 0 && !map.keys.first.endsWith("/")) {
        return displayElements().indexOf(map);
      }
    }
    return -1;
  }

  String getPathFromIndex(int index) {
    if (index < 0 || index >= displayElements().length) {
      return "Invalid index"; // 유효하지 않은 인덱스 처리
    }

    String path = "";
    for (int i = 0; i <= index; i++) {
      path += displayElements()[i].keys.first;
      if (i < index || displayElements()[i].keys.first.endsWith('/')) {
        path += '/';
      }
    }

    path = "/$path";
    path = path.substring(0, path.length - 1);

    return path;
  }

  // returns index of true ChapterList
  int realIndexOf(String path) {
    for (var chap in chapterList) {
      if (path.endsWith("/")) {
        if (chap.path == path) {
          return chapterList.indexOf(chap);
        }
      } else {
        if ("${chap.path}${chap.name}" == path) {
          return chapterList.indexOf(chap);
        }
      }
    }
    return -1;
  }

  void onChapterTilePressed(int index) {
    setState(() {
      var str = fullElements()[convertToPathStructureIndex(index)];
      if (!str.endsWith("/")) {
        widget.changeChapter(str);
        Future.delayed(const Duration(milliseconds: 10), () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          var str = displayElements()[index].keys.first;
          str =
              "${findParentPath(displayElements()[index].keys.first, index, displayElements()[index].values.first)}$str";
          if (!widget.visibleList.contains(str)) {
            widget.addVisibleList(str);
          } else {
            var toRemove = [];
            for (var v in widget.visibleList) {
              if (v.startsWith(str)) {
                toRemove.add(v);
              }
            }
            toRemove.add(str);
            for (var v in toRemove) {
              widget.removeVisibleList(v);
            }
          }
        });
      }
    });
  }

  /*String? findNearestFolder(int depthIndex) {
    print("/////////////////////////////////////////");
    int depth = displayElements()[depthIndex].values.first;
    print(depth);

    for(int i = depthIndex + 1; i < displayElements().length; i++) {
      int thisDepth = displayElements()[i].values.first;
      if(displayElements()[i].keys.first.endsWith("/") && depth == thisDepth) {
        var near = "/${displayElements()[i].keys.first}";
        near = generateFullPath(near, depthIndex, thisDepth);
        print("nearest folder : $near");
        return "/${displayElements()[i].keys.first}";
      }
    }

    if(depth == 0) {
      return "/";
    }
    else {
      return null;
    }*/
  //}

  int firstElementIndex(String folder) {
    print("First Element Index");
    if (!folder.startsWith("/")) {
      folder = "/$folder";
    }
    print("I $folder");

    for (var path in reducedElements()) {
      print("II folder: $folder, path: $path");
      if (path.startsWith(folder) && folder != "/") {
        print("III found: ${reducedElements().indexOf(path)}");
        return reducedElements().indexOf(path);
      }
    }
    print("Nearest folder is root path");

    for (var path in reducedElements()) {
      var depth = path.split("/").length;
      print("IV folder: $folder, path: $path, depth: $depth");
      if (depth <= 2) {
        print("V found: ${reducedElements().indexOf(path)}");
        return reducedElements().indexOf(path);
      }
    }
    print("ERRORRRRRR");
    return -1;
  }

  int calcFolderSize(String folder) {
    print("Calculate Folder Size");
    int i = 0;
    for (var path in reducedElements()) {
      if (path.startsWith(folder)) {
        i++;
      }
    }
    print("I size: $i");
    return i;
  }

  String nearestFolder(int gapIndex) {
    print("Nearest Folder");

    int depth = displayElements()[gapIndex].values.first;
    String str = displayElements()[gapIndex].keys.first;
    String? f;

    print("I gapIndex: $gapIndex, depth: $depth, str: $str");
    for (int i = gapIndex; i < displayElements().length; i++) {
      var folder = displayElements()[i].keys.first;
      print("II folder: $folder i:$i");
      if (folder.endsWith("/")) {
        print("found: $folder");
        f = folder;
        break;
      }
    }
    print("III Next step: ${f ?? "null"}");
    if (f != null) {
      print("IV out f: ${generateFullPath(f, gapIndex, depth)}");
      return generateFullPath(f, gapIndex, depth);
    } else {
      if (depth != 0) {
        if (str.endsWith("/")) {
          print("V folder: $str");
          return str;
        } else {
          print("VI Chapter found");
          return findParentPath(str, gapIndex, depth);
        }
      }
      return "/";
    }
  }

  @override
  void initState() {
    loadImage();
    controller = ScrollController();
    selectedIndex = -1;
    hoveringIndex = -1;
    gapIndex = -1;
    bScrolling = false;
    chapterList = [];
    pathList = [];

    for (var chap in widget.subjectData.wordlist) {
      chapterList.add(chap);
    }

    for (var chap in widget.subjectData.wordlist) {
      if (!pathList.contains(chap.path)) {
        pathList.add(chap.path); // saved in sorted ver.
      }
    }
    pushDefaultToBehind();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChapterSelectionDrawer oldWidget) {
    loadImage();
    updateLists(widget.subjectData.wordlist);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Column(
        children: [
          GestureDetector(
            onLongPress: addThumbnail,
            onTap: () {
              openSubjectNameEditor(context);
            },
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                DrawerThumbnail(
                  image: _loadedImage ??
                      const Image(
                        image: AssetImage('assets/400x400.jpg'),
                        width: 300,
                      ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Stack(
                    children: [
                      Text(
                        widget.subjectData.title,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = Colors.white,
                            shadows: const [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 10,
                              ),
                            ]),
                      ),
                      Text(
                        widget.subjectData.title,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("Add Folder"),
              IconButton(
                onPressed: () {
                  openFolderAdder(context);
                },
                icon: const Icon(Icons.add),
                splashRadius: 0.1,
              ),
              const Text("Add Chapter"),
              IconButton(
                onPressed: () {
                  openChapterTitleEditor(context);
                },
                icon: const Icon(Icons.add),
                splashRadius: 0.1,
              ),
              if (AppConfig.bDebugMode)
                IconButton(
                  onPressed: widget.duplicateChapter,
                  icon: const Icon(Icons.control_point_duplicate),
                  splashRadius: 0.1,
                ),
            ],
          ),
          Expanded(
            key: listViewKey,
            child: GestureDetector(
              onLongPressStart: (details) {
                setState(() {
                  selectedIndex = calcPointingIndex(
                      details.localPosition.dy, controller.offset, 50);
                  if (kDebugMode) {
                    print(selectedIndex);
                  }
                });
              },
              onLongPressMoveUpdate: (details) {
                setState(() {
                  // Update pointing indexes
                  hoveringIndex = calcPointingIndex(
                      details.localPosition.dy, controller.offset, 50);
                  gapIndex = calcPointingGapIndex(
                      details.localPosition.dy, controller.offset, 50);

                  // Scroll
                  if (details.localPosition.dy < 10) {
                    // Scroll upwards
                    requestScroll(0, 0.5, controller.offset);
                  } else if (details.localPosition.dy >
                      listViewKey.currentContext!.size!.height - 10) {
                    // Scroll downwards
                    var size = calcSize();
                    var destination = ((size + 1) * 50) -
                        listViewKey.currentContext!.size!.height;
                    requestScroll(destination, 0.5, controller.offset);
                  } else {
                    // Stop scroll
                    stopScroll();
                  }
                });
              },
              onLongPressUp: () {
                setState(() {
                  if(selectedIndex < displayElements().length) {
                    int trueIndex = convertToPathStructureIndex(selectedIndex);
                    String target = findElement(trueIndex);
                    String destination = "/";
                    int destinationIndex = -1;

                    String targetOldName = findElement(trueIndex).split("/").last;
                    String targetPathOnly = findElement(trueIndex).substring(0,
                        (findElement(trueIndex).length - targetOldName.length));
                    destination = targetPathOnly; // start point

                    // calc destination
                    if (gapIndex == 0) {
                      destination = "/";
                      destinationIndex = 0;
                    } else if (gapIndex == selectedIndex ||
                        gapIndex == selectedIndex + 1) {
                      destination = targetPathOnly;
                      destinationIndex = -1;
                    } else {
                      var path = generateFullPath(
                          displayElements()[gapIndex - 1].keys.first,
                          gapIndex - 1,
                          displayElements()[gapIndex - 1].values.first);
                      if (path.endsWith("/")) {
                        destination = path;
                      } else {
                        destination = parentPath(path);
                      }

                      if (!path.endsWith("/")) {
                        destinationIndex = realIndexOf(path) + 1;
                      } else {
                        destinationIndex = realIndexOf(path);
                      }
                    }

                    // move
                    if (reducedElements().contains(fullElements()[
                    convertToPathStructureIndex(selectedIndex)])) {
                      widget.moveChapter(target, destination);
                      if (destinationIndex != -1) {
                        widget.reorderChapter(
                            "$destination$targetOldName", destinationIndex);
                      }
                    } else {
                      var str = generateFullPath(
                          displayElements()[selectedIndex].keys.first,
                          selectedIndex,
                          displayElements()[selectedIndex].values.first);

                      int start = firstElementIndex(str);
                      int size = calcFolderSize(str);

                      var targetingIndex = gapIndex - 1;
                      if (targetingIndex < 0) {
                        targetingIndex = 0;
                      }
                      int target = firstElementIndex(nearestFolder(gapIndex));

                      widget.insertChapters(start, size, target);
                    }
                  }

                  selectedIndex = -1;
                  hoveringIndex = -1;
                  gapIndex = -1;
                  stopScroll();
                });
              },
              child: ListView.builder(
                itemCount: displayElements().length,
                controller: controller,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  int target = index;
                  if (index >= rootIndex()) {
                    target = index;
                  }

                  String display =
                      displayElements().elementAt(target).keys.first;
                  int depth = displayElements().elementAt(target).values.first;
                  bool opened = widget.visibleList.contains("/$display") ||
                      widget.visibleList.contains(
                          generateFullPath("/$display", index, depth));
                  bool closed = display.endsWith("/");
                  bool selected = isSelected(target);
                  bool folder = display.endsWith("/");
                  bool hovering = selectedIndex != -1;
                  bool drag = selectedIndex == index;
                  bool hovered = index == gapIndex || index == gapIndex - 1;
                  bool upper = index == gapIndex;

                  display = display.replaceAll("/", "");

                  return Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.01),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            for (int i = 0; i < depth; i++)
                              const SizedBox(
                                width: 15,
                              ),
                            if (folder)
                              const SizedBox(
                                width: 15,
                              ),
                            if (!folder)
                              const SizedBox(
                                width: 15,
                              ),
                            if (folder)
                              TextButton.icon(
                                onPressed: () => onChapterTilePressed(index),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blueGrey,
                                ),
                                icon: Icon(
                                  opened ? Icons.folder_open : Icons.folder,
                                  color: Colors.black87,
                                ),
                                label: Text(
                                  display,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: drag ? 20 : 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            if (!folder)
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blueGrey,
                                ),
                                onPressed: () => onChapterTilePressed(index),
                                child: Text(
                                  display,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: drag ? 20 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (selected)
                              const Icon(
                                Icons.arrow_left,
                              ),
                          ],
                        ),
                        if (hovering && !upper && hovered)
                          Transform.translate(
                            offset: const Offset(0, 25),
                            child: Container(
                              height: 5,
                              width: double.infinity,
                              color: mintColor,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (Platform.isAndroid || Platform.isIOS)
                  IconButton(
                    onPressed: shareSubject,
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                  ),
                if (Platform.isWindows)
                  IconButton(
                    onPressed: () async {
                      final picker = DirectoryPicker()
                        ..title = 'Select a directory';
                      final result = picker.getDirectory();

                      if (result != null) {
                        final path = result.path;
                        File file =
                            File("$path/${widget.subjectData.title}.json");
                        await file.writeAsString(
                            SubjectDataModel.listToJson([widget.subjectData]));
                        Future.delayed(const Duration(milliseconds: 500), () {
                          launchUrlString(result.path);
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                  ),
                IconButton(
                  onPressed: () async {
                    widget.showLoadingScreen(context);
                    widget.saveData();
                    Future.delayed(const Duration(milliseconds: 1), () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "saved",
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                          elevation: 10,
                        ),
                      );
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  },
                  icon: const Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    widget.showLoadingScreen(context);
                    widget.saveData();
                    Future.delayed(
                        Duration(
                            milliseconds:
                                (calcTotalWordCount() * 1).toInt() + 100), () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
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

  int calcTotalWordCount() {
    var count = 0;
    for (var sub in SubjectDataModel.subjectList) {
      for (var chap in sub.wordlist) {
        count += chap.words.length;
      }
    }
    return count;
  }
}

class DrawerThumbnail extends StatelessWidget {
  const DrawerThumbnail({Key? key, required this.image}) : super(key: key);

  final Image image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 200,
      child: FittedBox(
        clipBehavior: Clip.hardEdge,
        fit: BoxFit.fitWidth,
        child: image,
      ),
    );
  }
}
