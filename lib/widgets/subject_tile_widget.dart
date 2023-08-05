import 'package:flutter/material.dart';
import 'package:vocabella/managers/data_handle_manager.dart';

import '../models/subject_data_model.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile(
      {Key? key,
      required this.subject,
      required this.openEditor})
      : super(key: key);

  final SubjectDataModel subject;
  final void Function(SubjectDataModel) openEditor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 150,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: FutureBuilder(
              future:
                  DataReadWriteManager.loadExistingImage(subject.thumb ?? ""),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    height: 424,
                    width: 300,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20,
                          offset: Offset(5, 5),
                          spreadRadius: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image(
                      image: FileImage(snapshot.data!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        const Image dummyImage = Image(
                          image: AssetImage('assets/400x400.jpg'),
                          width: 300,
                        );
                        return dummyImage;
                      },
                    ),
                  );
                }
                return const Image(
                  image: AssetImage("assets/400x400.jpg"),
                  height: 424,
                  width: 300,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
