import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hdx_tests/screen/stt_example.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SttTestMain extends StatefulWidget {
  const SttTestMain({super.key});

  @override
  State<SttTestMain> createState() => _SttTestMainState();
}

class _SttTestMainState extends State<SttTestMain> {
  bool _hasSpeech = false;
  bool isListening = false;
  final bool _logEvents = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    try {
      var hasSpeech = await speech.initialize(
        onStatus: statusListener,
        debugLogging: _logEvents,
      );
      if (hasSpeech) {
        _localeNames = await speech.locales();
        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
      if (!mounted) return;
      setState(() {
        _hasSpeech = hasSpeech;
      });
    } catch (e) {
      setState(() {
        lastError = 'Speech recognition failed: ${e.toString()}';
        _hasSpeech = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "STT TEST",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("STT example"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpeechSampleApp(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Recognized Words',
              style: TextStyle(fontSize: 22.0),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 4,
            child: Stack(
              children: <Widget>[
                Container(
                  color: Colors.blue[50],
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
                        color: Colors.red,
                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  IconButton(
                    onPressed: !_hasSpeech || speech.isListening ? null : startListening,
                    icon: const Icon(Icons.mic, size: 50),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 0.0),
                    child: const Text(
                      "click to start!",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SpeechStatusWidget(speech: speech),
          SpeechControlWidget(
            _hasSpeech,
            speech.isListening,
            startListening,
            stopListening,
          ),
          const SizedBox(height: 15),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(items: items),
    );
  }

  void startListening() {
    _logEvent('start listening');
    lastWords = '';
    lastError = '';
    speech.listen(
      onResult: resultListener,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 10),
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
        autoPunctuation: true,
        enableHapticFeedback: true,
      ),
    );
    setState(() {});
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    _logEvent('Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    debugPrint('Recognized Words: ${result.recognizedWords}');
    setState(() {
      lastWords = '${result.recognizedWords} - ${result.finalResult}';
      // lastWords = result.recognizedWords;
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  void statusListener(String status) {
    _logEvent('Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = status;
    });
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      debugPrint('$eventTime $eventDescription');
    }
  }
}

// control
class SpeechControlWidget extends StatelessWidget {
  const SpeechControlWidget(this.hasSpeech, this.isListening, this.startListening, this.stopListening, {super.key});

  final bool hasSpeech;
  final bool isListening;
  final void Function() startListening;
  final void Function() stopListening;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TextButton(
          onPressed: !hasSpeech || isListening ? null : startListening,
          child: const Text('Start'),
        ),
        TextButton(
          onPressed: isListening ? stopListening : null,
          child: const Text('Stop'),
        ),
      ],
    );
  }
}

class SpeechStatusWidget extends StatelessWidget {
  const SpeechStatusWidget({
    super.key,
    required this.speech,
  });

  final SpeechToText speech;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: speech.isListening
            ? const Text(
                "I'm listening...",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              )
            : const Text(
                'Not listening',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';

// class SttTtsApp extends StatefulWidget {
//   const SttTtsApp({super.key});

//   @override
//   State<SttTtsApp> createState() => _SttTtsAppState();
// }

// class _SttTtsAppState extends State<SttTtsApp> {
//   final SpeechToText _speechToText = SpeechToText();
//   final FlutterTts _flutterTts = FlutterTts();

//   bool _isListening = false; // STT 상태
//   bool _speechEnabled = false; // STT 초기화 상태
//   String _recognizedText = ""; // 변환된 텍스트

//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//     _initTts();
//   }

//   // STT 초기화
//   Future<void> _initSpeech() async {
//     _speechEnabled = await _speechToText.initialize(
//       onStatus: (status) => print("STT Status: $status"),
//       onError: (error) => print("STT Error: ${error.errorMsg}"),
//     );
//     setState(() {});
//   }

//   // TTS 초기화
//   Future<void> _initTts() async {
//     await _flutterTts.setLanguage("en-US"); // 언어 설정
//     await _flutterTts.setPitch(1.0); // 음성 톤 설정
//     await _flutterTts.setSpeechRate(0.5); // 속도 설정
//   }

//   // 음성을 텍스트로 변환(STT 시작)
//   void _startListening() async {
//     if (_speechEnabled) {
//       setState(() {
//         _isListening = true;
//         _recognizedText = ""; // 초기화
//       });
//       await _speechToText.listen(
//         onResult: _onSpeechResult,
//         listenFor: const Duration(seconds: 30),
//         pauseFor: const Duration(seconds: 5),
//         localeId: "ko_KR", // 언어 설정
//       );
//     }
//   }

//   // 음성 텍스트 변환(STT 결과)
//   void _onSpeechResult(SpeechRecognitionResult result) {
//     setState(() {
//       _recognizedText = result.recognizedWords;
//     });
//   }

//   // STT 종료
//   void _stopListening() async {
//     await _speechToText.stop();
//     setState(() {
//       _isListening = false;
//     });
//   }

//   // 텍스트를 음성으로 변환(TTS)
//   void _speak() async {
//     if (_recognizedText.isNotEmpty) {
//       await _flutterTts.speak(_recognizedText);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('STT + TTS Example'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 인식된 텍스트 표시
//             const Text(
//               "Recognized Text:",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 _recognizedText.isEmpty ? "Say something..." : _recognizedText,
//                 style: const TextStyle(fontSize: 18),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // 버튼: STT 시작, STT 정지, TTS 변환
//             Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: _isListening ? null : _startListening,
//                   child: const Text("Start Listening"),
//                 ),
//                 ElevatedButton(
//                   onPressed: !_isListening ? null : _stopListening,
//                   child: const Text("Stop Listening"),
//                 ),
//                 ElevatedButton(
//                   onPressed: _recognizedText.isEmpty ? null : _speak,
//                   child: const Text("Speak"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }