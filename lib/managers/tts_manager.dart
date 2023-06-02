import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TTSButton extends StatefulWidget {
  TTSButton({Key? key, required this.textToRead, required this.language})
      : super(key: key);

  final String textToRead;
  final String language;

  late void Function() play;
  late void Function() stop;

  @override
  State<TTSButton> createState() => _TTSButtonState();
}

class _TTSButtonState extends State<TTSButton> {
  bool canPlaySound = true;
  bool isPlayingSound = false;

  FlutterTts flutterTts = FlutterTts();
  TtsState ttsState = TtsState.stopped;

  void _init() async {
    await flutterTts.setLanguage(widget.language);
    await flutterTts.setSpeechRate(0.5);
    setState(() {});

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });
  }

  void _speak() async {
    _init();
    if (canPlaySound) {
      await flutterTts.speak(widget.textToRead);
      isPlayingSound = true;
    }
    setState(() {});
  }

  void _stop() async {
    await flutterTts.stop();
    isPlayingSound = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    widget.play = _speak;
    widget.stop = _stop;

    _init();
  }

  @override
  Widget build(BuildContext context) {
    // TODO some day... I'll make indicator for if sound is playing...

    widget.play = _speak;
    widget.stop = _stop;

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
      child: IconButton(
        onPressed: isPlayingSound ? _stop : _speak,
        enableFeedback: false,
        icon: const Icon(
          Icons.audiotrack_rounded,
          size: 35,
        ),
      ),
    );
  }
}
