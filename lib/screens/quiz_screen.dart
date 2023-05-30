import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabella/widgets/progress_bar_widget.dart';
import 'package:vocabella/widgets/word_card_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Variables about input
  final fieldText = TextEditingController();
  String inputValue = "";

  // Variables about words
  String answer = "Datei";

  // Variables about quiz
  bool wasWrong = false;

  void onSummit(String text) {
    if (text == answer) {
      wasWrong = false;
    } else {
      wasWrong = true;
      fieldText.clear();
      setState(() {});
    }
  }

  void onSummitByButton() {
    if (inputValue == answer) {
      wasWrong = false;
    } else {
      wasWrong = true;
      fieldText.clear();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
          ),
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          ProgressBar(),
          const SizedBox(
            height: 20,
          ),
          Flexible(
            flex: 1,
            child: WordCard(),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              /*borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),*/
              color: Colors.grey,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 10,
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
            height: MediaQuery.of(context).size.height * 0.09,
            child: Padding(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
              child: Container(
                color: Colors.white,
                child: Transform.translate(
                  offset: const Offset(0, 6),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      floatingLabelAlignment: FloatingLabelAlignment.start,
                      hintText: wasWrong ? answer : "",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send_rounded),
                        color: Colors.grey.withOpacity(0.5),
                        onPressed: onSummitByButton,
                      ),
                      prefixIcon: Icon(
                        Icons.keyboard_alt_outlined,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                    ),
                    controller: fieldText,
                    cursorColor: Colors.grey.withOpacity(0.5),
                    textAlign: TextAlign.center,
                    onChanged: (text) {
                      inputValue = text;
                    },
                    onSubmitted: onSummit,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

