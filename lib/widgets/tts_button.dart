import 'package:flutter/material.dart';
import 'package:vocabella/managers/tts_voice_manager.dart';

enum TtsState { playing, stopped, paused, continued }

class TTSButton extends StatelessWidget {
  const TTSButton({
    Key? key,
    required this.textToRead,
    required this.language,
  }) : super(key: key);

  final String textToRead;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(90),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).cardColor.withOpacity(0),
            blurRadius: 10,
          ),
        ],
      ),
      child: IgnorePointer(
        ignoring: false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            print("tapped");
            TTSManager.requestPlay(TTSQueue(text: textToRead, language: language));
          },
          child: const Icon(
            Icons.audiotrack_rounded,
            size: 40,
          ),
        ),
      ),
    );
  }
}
