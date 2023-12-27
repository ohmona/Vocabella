import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/chapter_model.dart';

class EditorScreenAppbar extends StatefulWidget {
  const EditorScreenAppbar({
    Key? key,
    required this.currentChapter,
    required this.bShowingWords,
    required this.toggleWords,
    required this.bDeleteMode,
    required this.toggleDeleteMode,
    required this.changeChapterName,
    required this.wordCount,
    required this.bReadOnly,
    required this.toggleReadOnly,
    required this.chapterName,
    required this.bFavourite,
    required this.changeFavourite,
    required this.getFavourite, required this.favouriteCount,
  }) : super(key: key);

  final Chapter currentChapter;
  final bool bShowingWords;
  final bool bDeleteMode;
  final bool bFavourite;
  final bool bReadOnly;
  final int wordCount;
  final int favouriteCount;
  final String chapterName;
  final void Function() toggleWords;
  final void Function() toggleDeleteMode;
  final void Function() toggleReadOnly;
  final void Function() changeFavourite;
  final void Function(String) changeChapterName;
  final bool Function() getFavourite;

  @override
  State<EditorScreenAppbar> createState() => _EditorScreenAppbarState();
}

class _EditorScreenAppbarState extends State<EditorScreenAppbar> {
  TextEditingController controller = TextEditingController();

  bool favourite = false;

  Future<void> openChapterNameEditor(BuildContext context) {
    controller.text = widget.chapterName;

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Type the new title of the chapter"),
          content: TextField(
            controller: controller,
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
                if (controller.text.isNotEmpty) {
                  widget.changeChapterName(controller.text);

                  controller.text = "";
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

  @override
  void initState() {
    super.initState();
  }

  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).cardColor.withOpacity(0.5),
            blurRadius: 10,
            blurStyle: BlurStyle.normal,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      height: 60,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              },
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    openChapterNameEditor(context);
                  },
                  style: const ButtonStyle(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(
                    "${widget.currentChapter.name} (${widget.wordCount}/${widget.favouriteCount})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {
                if (kDebugMode) {
                  print("change favourite");
                  print("Favourite : $favourite");
                }
                setState(() {
                  widget.changeFavourite();
                });
              },
              icon: Icon(
                widget.getFavourite() ? Icons.star : Icons.star_border_outlined,
                color: Colors.white,
              ),
            ),
            MenuAnchor(
              childFocusNode: _buttonFocusNode,
              menuChildren: <Widget>[
                MenuItemButton(
                  onPressed: () {
                    widget.toggleWords();
                  },
                  child: Text(
                    widget.bShowingWords ? "Showing words" : "Showing examples",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                MenuItemButton(
                  onPressed: () {
                    if (widget.bShowingWords) {
                      widget.toggleDeleteMode();
                    }
                  },
                  child: Text(
                    widget.bDeleteMode
                        ? "Delete mode (on)"
                        : "Delete mode (off)",
                    style: TextStyle(
                      color:
                          widget.bDeleteMode ? Colors.redAccent : Colors.white,
                    ),
                  ),
                ),
                MenuItemButton(
                  onPressed: () {
                    widget.toggleReadOnly();
                  },
                  child: Text(
                    widget.bReadOnly ? "Read only (on)" : "Read only (off)",
                    style: TextStyle(
                      color: widget.bReadOnly ? Colors.green : Colors.white,
                    ),
                  ),
                ),
              ],
              builder: (BuildContext context, MenuController controller,
                  Widget? child) {
                return TextButton(
                  focusNode: _buttonFocusNode,
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.resolveWith<Size?>(
                      (states) {
                        return const Size(20, 20);
                      },
                    ),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (states) {
                        return Colors.white.withOpacity(0.3);
                      },
                    ),
                  ),
                  child: const Icon(
                    Icons.add_circle,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
