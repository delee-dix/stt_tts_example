import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TtsService {
  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  String? language;
  String? engine;
  String? _newVoiceText;
  double speechRate = 0.5;
  bool isCurrentLanguageInstalled = false;

  TtsService() {
    flutterTts = FlutterTts();
    _initTtsHandlers();
    _setAwaitOptions();
    if (Platform.isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }
  }

  void _initTtsHandlers() {
    flutterTts.setStartHandler(() => ttsState = TtsState.playing);
    flutterTts.setCompletionHandler(() => ttsState = TtsState.stopped);
    flutterTts.setCancelHandler(() => ttsState = TtsState.stopped);
    flutterTts.setPauseHandler(() => ttsState = TtsState.paused);
    flutterTts.setContinueHandler(() => ttsState = TtsState.continued);
    flutterTts.setErrorHandler((msg) => ttsState = TtsState.stopped);
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<dynamic> getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> getEngines() async => await flutterTts.getEngines;

  Future<void> _getDefaultEngine() async {
    engine = await flutterTts.getDefaultEngine;
  }

  Future<void> _getDefaultVoice() async {
    print("Default voice data: $language");
    language = await flutterTts.getDefaultVoice;
  }

  void setVoiceText(String text) {
    _newVoiceText = text;
  }

  Future<void> speak() async {
    if (_newVoiceText != null && _newVoiceText!.isNotEmpty) {
      await flutterTts.setSpeechRate(speechRate);
      await flutterTts.speak(_newVoiceText!);
    }
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }

  Future<void> pause() async {
    await flutterTts.pause();
  }

  void dispose() {
    flutterTts.stop();
  }

  Future<void> changedEngines(String? selectedEngine) async {
    engine = selectedEngine;
    await flutterTts.setEngine(selectedEngine!);
    language = null;
  }

  Future<void> changedLanguage(String? selectedType) async {
    language = selectedType;
    flutterTts.setLanguage(language!);
    if (Platform.isAndroid) {
      isCurrentLanguageInstalled = await flutterTts.isLanguageInstalled(language!);
    }
  }
}
