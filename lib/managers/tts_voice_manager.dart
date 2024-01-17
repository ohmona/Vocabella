import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabella/utils/short_languages.dart';

class TTSQueue {
  TTSQueue({
    required this.text,
    required this.language,
  });

  final String text;
  final String language;

  void printAll() {
    if (kDebugMode) {
      print("=======================");
      print(text);
      print(language);
    }
  }
}

class TTSManager {
  static late FlutterTts instance;

  static void init() async {
    instance = FlutterTts();
    await instance.setSpeechRate(0.5);
    queue = [];
    isPlaying = false;
  }

  static late List<TTSQueue> queue;
  static late bool isPlaying;

  static void requestPlay(TTSQueue queueObj) async {
    queueObj.printAll();
    if(!existSameAs(queueObj.text)) {
      if (queue.length >= 2) {
        print("resetting queue");
        stop();
        queue.add(queueObj);
        play();
      }
      else if (queue.length == 1) {
        print("queuing");
        queue.add(queueObj);
      }
      else {
        print("starting");
        queue.add(queueObj);
        play();
      }
    }
    else {
      if(queue[0].text == queueObj.text) {
        stop();
      }
    }
  }

  static bool existSameAs(String target) {
    for(var obj in queue) {
      if(obj.text == target) {
        print("Text already given!");
        return true;
      }
    }
    print("new text coming");
    return false;
  }

  static void play() async {
    isPlaying = true;

    instance.setCompletionHandler(_onComplete);

    print("playing...");
    queue[0].printAll();
    await instance.setLanguage(queue[0].language);
    await instance.speak(formatText(queue[0].text));
  }

  static void _onComplete() {
    print("play complete");
    if(queue.length > 1) {
      print("pushing queue...");
      for (int i = 0; i < queue.length - 1; i++) {
        queue[i] = queue[i + 1];
        print("moving $i");
        queue[i].printAll();
      }
      queue.removeLast();
      isPlaying = false;
      play();
    }
    else {
      print("play done");
      queue.removeLast();
      isPlaying = false;
    }
  }

  static void stop() async {
    print("stop method");
    if(isPlaying) {
      print("stopping...");
      queue = [];
      isPlaying = false;
      await instance.stop();
    }
  }
}
