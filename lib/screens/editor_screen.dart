import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vocabella/widgets/word_grid_tile_widget.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
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
              padding: const EdgeInsets.all(60 / 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Welcome to editor",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: 100,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 6 / 1,
              ),
              itemBuilder: ((context, index) {
                return const WordGridTile(text: "lol");
              }),
            ),
          ),
        ],
      ),
    );
  }
}
