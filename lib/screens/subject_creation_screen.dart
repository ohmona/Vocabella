import 'package:flutter/material.dart';
import 'package:vocabella/constants.dart';

import '../arguments.dart';

class SubjectCreationScreenParent extends StatelessWidget {
  const SubjectCreationScreenParent({Key? key}) : super(key: key);

  static const routeName = "/create";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as SubjectCreationScreenArguments;

    return SubjectCreationScreen(
      createNewSubject: args.createNewSubject,
    );
  }
}

class SubjectCreationScreen extends StatefulWidget {
  const SubjectCreationScreen({Key? key, required this.createNewSubject})
      : super(key: key);

  static const routeName = "/create";

  final void Function({
    required String newTitle,
    required String newSubject1,
    required String newSubject2,
    required String newLanguage1,
    required String newLanguage2,
    required String newChapter,
  }) createNewSubject;

  @override
  State<SubjectCreationScreen> createState() => _SubjectCreationScreenState();
}

class _SubjectCreationScreenState extends State<SubjectCreationScreen> {
  TextEditingController titleCtr = TextEditingController();
  TextEditingController firstSubCtr = TextEditingController();
  TextEditingController secondSubCtr = TextEditingController();
  String firstLang = "en-US";
  String secondLang = "en-US";
  TextEditingController chapterCtr = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new subject"),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: bgGradient,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Column(
            children: [
              const SizedBox(
                height: 60,
              ),
              const Divider(),
              const SizedBox(
                height: 60,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Create your own unique subject \nto improve your language skill!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 60,
              ),
              const Divider(),
              const SizedBox(
                height: 60,
              ),
              InformationInputBox(
                title: "Title of new subject",
                label: "title",
                controller: titleCtr,
                widgetWidth: MediaQuery.of(context).size.width - 40,
                focusNode: focusNode1,
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      InformationInputBox(
                        title: "Name of first subject",
                        label: "name",
                        controller: firstSubCtr,
                        widgetWidth: MediaQuery.of(context).size.width - 160,
                        focusNode: focusNode2,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        firstLang,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      PopupMenuButton(
                        icon: Icon(
                          Icons.language,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        color: Colors.white,
                        initialValue: firstLang,
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
                            firstLang = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      InformationInputBox(
                        title: "Name of second subject",
                        label: "name",
                        controller: secondSubCtr,
                        widgetWidth: MediaQuery.of(context).size.width - 160,
                        focusNode: focusNode3,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        secondLang,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      PopupMenuButton(
                        icon: Icon(
                          Icons.language,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        color: Colors.white,
                        initialValue: secondLang,
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
                            secondLang = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(),
              const SizedBox(
                height: 30,
              ),
              InformationInputBox(
                title: "Title of the first chapter",
                label: "title",
                controller: chapterCtr,
                widgetWidth: MediaQuery.of(context).size.width - 40,
                focusNode: focusNode4,
              ),
              const SizedBox(
                height: 60,
              ),
              TextButton(
                onPressed: () {
                  focusNode1.unfocus();
                  focusNode2.unfocus();
                  focusNode3.unfocus();
                  focusNode4.unfocus();

                  if (titleCtr.text.isNotEmpty &&
                      firstSubCtr.text.isNotEmpty &&
                      secondSubCtr.text.isNotEmpty &&
                      firstLang.isNotEmpty &&
                      secondLang.isNotEmpty &&
                      chapterCtr.text.isNotEmpty) {
                    widget.createNewSubject(
                      newChapter: chapterCtr.text,
                      newLanguage1: firstLang,
                      newLanguage2: secondLang,
                      newSubject1: firstSubCtr.text,
                      newSubject2: secondSubCtr.text,
                      newTitle: titleCtr.text,
                    );
                  }
                },
                style: ButtonStyle(
                  overlayColor:
                      MaterialStateProperty.all(Colors.white.withOpacity(0.5)),
                ),
                child: const Text(
                  "create",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              const Text(
                "If you want to load existing file, press add \n button (right-top) on home screen",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InformationInputBox extends StatelessWidget {
  const InformationInputBox(
      {Key? key,
      required this.title,
      required this.label,
      required this.controller,
      required this.widgetWidth,
      required this.focusNode})
      : super(key: key);

  final String title;
  final String label;

  final double widgetWidth;

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 60,
          width: widgetWidth,
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: TextField(
            focusNode: focusNode,
            decoration: InputDecoration(
                focusColor: Colors.white,
                labelStyle: const TextStyle(
                  color: Colors.white,
                ),
                border: InputBorder.none,
                label: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                )),
            controller: controller,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
