import 'package:flutter/material.dart';
import 'package:vocabella/utils/constants.dart';
import 'package:vocabella/models/removed_subject_model.dart';

class RecycleBinGridTile extends StatelessWidget {
  const RecycleBinGridTile({
    Key? key,
    required this.data,
    required this.index,
    required this.restoreSubject,
    required this.openDeleteConfirmation,
  }) : super(key: key);

  final RemovedSubjectModel data;
  final int index;

  final void Function(int) restoreSubject;
  final void Function(BuildContext, int) openDeleteConfirmation;

  int calcExpiration() {
    final difference = data.removeDate!.add(expirationDuration).difference(DateTime.now());
    return difference.inHours + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    data.title,
                    style:
                        const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  calcExpiration() > 1 ? "expired in ${calcExpiration()} hours" : "expired in ${calcExpiration()} hour",
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  restoreSubject(index);
                },
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                onPressed: () {
                  openDeleteConfirmation(context, index);
                },
                icon: const Icon(Icons.remove_circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
