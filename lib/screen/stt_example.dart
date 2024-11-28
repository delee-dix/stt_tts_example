import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hdx_tests/service/stt_example.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechSampleApp extends StatefulWidget {
  const SpeechSampleApp({super.key});

  @override
  State<SpeechSampleApp> createState() => _SpeechSampleAppState();
}

class _SpeechSampleAppState extends State<SpeechSampleApp> {
  final SpeechService speechService = SpeechService();
  final TextEditingController _pauseForController = TextEditingController(text: '3');
  final TextEditingController _listenForController = TextEditingController(text: '30');
  // bool _hasSpeech = false;
  // bool _logEvents = false;
  // bool _onDevice = false;
  // double level = 0.0;
  // double minSoundLevel = 50000;
  // double maxSoundLevel = -50000;
  // String lastWords = '';
  // String lastError = '';
  // String lastStatus = '';
  // String _currentLocaleId = '';
  // List<LocaleName> _localeNames = [];
  // final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
    initializeSpeech();
  }

  Future<void> initializeSpeech() async {
    await speechService.initSpeechState((error) {
      speechService.lastError = error;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('STT Example'),
        ),
        body: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            SpeechControlWidget(
              speechService.hasSpeech,
              speechService.isListening,
              startListening,
              stopListening,
              cancelListening,
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 4,
              child: RecognitionResultsWidget(
                lastWords: speechService.lastWords,
                level: speechService.level,
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: <Widget>[
                  const Center(
                    child: Text(
                      'Error Status',
                      style: TextStyle(fontSize: 22.0),
                    ),
                  ),
                  Center(
                    child: SelectableText(speechService.lastError),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: speechService.isListening
                    ? const Text(
                        "I'm listening...",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      )
                    : const Text(
                        'Not listening',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startListening() {
    final pauseFor = int.tryParse(_pauseForController.text) ?? 3;
    final listenFor = int.tryParse(_listenForController.text) ?? 30;

    speechService.startListening(
      localeId: speechService.currentLocaleId,
      pauseFor: pauseFor,
      listenFor: listenFor,
      onResult: (result) {
        setState(() {
          speechService.lastWords = result.recognizedWords;
        });
      },
      onSoundLevelChange: (level) {
        setState(() {
          speechService.level = level;
        });
      },
    );
  }

  void stopListening() {
    speechService.stopListening();
  }

  void cancelListening() {
    speechService.cancelListening();
  }
}

class RecognitionResultsWidget extends StatelessWidget {
  const RecognitionResultsWidget({
    super.key,
    required this.lastWords,
    required this.level,
  });

  final String lastWords;
  final double level;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Center(
          child: Text(
            '<< Recognized Words >>',
            style: TextStyle(fontSize: 22.0),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                color: Theme.of(context).secondaryHeaderColor,
                child: Center(
                  child: Text(
                    lastWords,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned.fill(
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(blurRadius: .26, spreadRadius: level * 1.5, color: Colors.black.withOpacity(.05))],
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SpeechControlWidget extends StatelessWidget {
  const SpeechControlWidget(
    this.hasSpeech,
    this.isListening,
    this.startListening,
    this.stopListening,
    this.cancelListening, {
    super.key,
  });

  final bool hasSpeech;
  final bool isListening;
  final void Function() startListening;
  final void Function() stopListening;
  final void Function() cancelListening;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        ElevatedButton(
          onPressed: !hasSpeech || isListening ? null : startListening,
          child: const Text(
            'Start',
            style: TextStyle(color: Colors.green),
          ),
        ),
        ElevatedButton(
          onPressed: isListening ? stopListening : null,
          child: const Text(
            'Stop',
            style: TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: isListening ? cancelListening : null,
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.orange),
          ),
        )
      ],
    );
  }
}

class SessionOptionsWidget extends StatelessWidget {
  const SessionOptionsWidget(
    this.currentLocaleId,
    this.switchLang,
    this.localeNames,
    this.logEvents,
    this.switchLogging,
    this.pauseForController,
    this.listenForController,
    this.onDevice,
    this.switchOnDevice, {
    super.key,
  });

  final String currentLocaleId;
  final void Function(String?) switchLang;
  final void Function(bool?) switchLogging;
  final void Function(bool?) switchOnDevice;
  final TextEditingController pauseForController;
  final TextEditingController listenForController;
  final List<LocaleName> localeNames;
  final bool logEvents;
  final bool onDevice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              const Text('Language: '),
              DropdownButton<String>(
                onChanged: (selectedVal) => switchLang(selectedVal),
                value: currentLocaleId,
                items: localeNames
                    .map(
                      (localeName) => DropdownMenuItem(
                        value: localeName.localeId,
                        child: Text(localeName.name),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          Row(
            children: [
              const Text('pauseFor: '),
              Container(
                  padding: const EdgeInsets.only(left: 8),
                  width: 80,
                  child: TextFormField(
                    controller: pauseForController,
                  )),
              Container(padding: const EdgeInsets.only(left: 16), child: const Text('listenFor: ')),
              Container(
                  padding: const EdgeInsets.only(left: 8),
                  width: 80,
                  child: TextFormField(
                    controller: listenForController,
                  )),
            ],
          ),
          Row(
            children: [
              const Text('On device: '),
              Checkbox(
                value: onDevice,
                onChanged: switchOnDevice,
              ),
              const Text('Log events: '),
              Checkbox(
                value: logEvents,
                onChanged: switchLogging,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
