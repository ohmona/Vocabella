import 'package:flutter/material.dart';
import 'package:vocabella/arguments.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key})
      : super(key: key);

  static const routeName = '/result';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ResultScreenArguments;
    
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Result'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total Words: ${args.total}'),
              const SizedBox(height: 10),
              Text('In First Try Percentage: ${args.inFirstTry * 100}%'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/')); // Navigate back to the previous screen
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
