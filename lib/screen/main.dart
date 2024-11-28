import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SttTtsApp extends StatefulWidget {
  const SttTtsApp({super.key});

  @override
  State<SttTtsApp> createState() => _SttTtsAppState();
}

class _SttTtsAppState extends State<SttTtsApp> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false; // STT 상태
  bool _speechEnabled = false; // STT 초기화 상태
  String _recognizedText = ""; // 변환된 텍스트

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  // STT 초기화
  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => print("STT Status: $status"),
      onError: (error) => print("STT Error: ${error.errorMsg}"),
    );
    setState(() {});
  }

  // TTS 초기화
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US"); // 언어 설정
    await _flutterTts.setPitch(1.0); // 음성 톤 설정
    await _flutterTts.setSpeechRate(0.5); // 속도 설정
  }

  // 음성을 텍스트로 변환(STT 시작)
  void _startListening() async {
    if (_speechEnabled) {
      setState(() {
        _isListening = true;
        _recognizedText = ""; // 초기화
      });
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        localeId: "ko_KR", // 언어 설정
      );
    }
  }

  // 음성 텍스트 변환(STT 결과)
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
    });
  }

  // STT 종료
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  // 텍스트를 음성으로 변환(TTS)
  void _speak() async {
    if (_recognizedText.isNotEmpty) {
      await _flutterTts.speak(_recognizedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('STT + TTS Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 인식된 텍스트 표시
            const Text(
              "Recognized Text:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _recognizedText.isEmpty ? "Say something..." : _recognizedText,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            // 버튼: STT 시작, STT 정지, TTS 변환
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isListening ? null : _startListening,
                  child: const Text("Start Listening"),
                ),
                ElevatedButton(
                  onPressed: !_isListening ? null : _stopListening,
                  child: const Text("Stop Listening"),
                ),
                ElevatedButton(
                  onPressed: _recognizedText.isEmpty ? null : _speak,
                  child: const Text("Speak"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
