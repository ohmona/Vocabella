import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vocabella/managers/data_handle_manager.dart';
import 'package:vocabella/models/subject_data_model.dart';

class ChapterSelectionDrawer extends StatefulWidget {
  const ChapterSelectionDrawer({
    Key? key,
    required this.subjectData,
    required this.changeChapter,
    required this.getChapterName,
    required this.currentChapterIndex,
    required this.addChapter,
    required this.saveData,
    required this.changeThumbnail,
  }) : super(key: key);

  final SubjectDataModel subjectData;
  final void Function(String) changeChapter;
  final String Function(int) getChapterName;
  final int currentChapterIndex;
  final void Function(String) addChapter;
  final void Function() saveData;
  final void Function(String) changeThumbnail;

  static TextEditingController controller = TextEditingController();
  static String newTitle = "";

  @override
  State<ChapterSelectionDrawer> createState() => _ChapterSelectionDrawerState();
}

class _ChapterSelectionDrawerState extends State<ChapterSelectionDrawer> {
  Image? _loadedImage; // New variable to hold the loaded image

  Future<void> openChapterTitleEditor(BuildContext context) {
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
              child: const Text("cancel"),
            ),
            TextButton(
              onPressed: () {
                if (ChapterSelectionDrawer.controller.text.isNotEmpty) {
                  widget.addChapter(ChapterSelectionDrawer.controller.text);
                  ChapterSelectionDrawer.controller.text = "";
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

  Future<void> openDoubleChecker(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Attention!"),
          content: const Text("Are you sure you want to save and exit?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                widget.saveData();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text("Yes"),
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

    print("=======================================");
    print("Saved data : ${widget.subjectData.thumb}");
    DataReadWriteManager.loadExistingImage(widget.subjectData.thumb!)
        .then((value) {
      image = value;
      print("=======================================");
      print("is image valid? ${image != null}");

      if (image != null) {
        print("=======================================");
        print("Loaded data : ${image?.path}");
        setState(() {
          _loadedImage = Image(
            image: FileImage(image!),
          ); // Update the loaded image
        });
      } else {
        print("=======================================");
        print("Image couldn't be loaded");
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
    } else {
      print("Something went wrong...");
    }
  }

  @override
  void initState() {
    loadImage();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChapterSelectionDrawer oldWidget) {
    loadImage();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Column(
        children: [
          GestureDetector(
            onTap: addThumbnail,
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
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Stack(
                    children: [
                      Text(
                        widget.subjectData.title!,
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
                        widget.subjectData.title!,
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
          Expanded(
            child: ListView.separated(
              itemCount: widget.subjectData.wordlist!.length,
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
                      widget.changeChapter(widget.getChapterName(index));
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(15),
                          child: Text(
                            widget.subjectData.wordlist![index].name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        (widget.currentChapterIndex == index)
                            ? const Icon(Icons.arrow_left)
                            : Container(),
                      ],
                    ),
                  ),
                );
              },
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
                IconButton(
                  onPressed: () {
                    widget.saveData();
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
                  },
                  icon: const Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    openDoubleChecker(context);
                  },
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
