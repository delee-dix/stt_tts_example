import 'dart:async';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  bool _logEvents = false;
  bool _onDevice = false;

  List<LocaleName> _localeNames = [];
  List<LocaleName> get localeNames => _localeNames;
  String _currentLocaleId = '';
  String get currentLocaleId => _currentLocaleId;
  bool get hasSpeech => _hasSpeech;
  bool _hasSpeech = false;

  String lastWords = '';
  String lastError = '';
  String lastStatus = '';

  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  bool get isListening => _speech.isListening;

  Future<void> initSpeechState(Function(String) onError) async {
    try {
      _hasSpeech = await _speech.initialize(
        onError: (error) => onError(error.errorMsg),
        onStatus: (status) => logEvent('Status: $status'),
        debugLogging: _logEvents,
      );

      if (_hasSpeech) {
        _localeNames = await _speech.locales();
        var systemLocale = await _speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
    } catch (e) {
      lastError = 'Speech recognition initialization failed: $e';
    }
  }

  void startListening({
    required Function(SpeechRecognitionResult) onResult,
    required Function(double) onSoundLevelChange,
    required String localeId,
    required int pauseFor,
    required int listenFor,
  }) {
    _speech.listen(
      onResult: onResult,
      localeId: localeId,
      listenFor: Duration(seconds: listenFor),
      pauseFor: Duration(seconds: pauseFor),
      onSoundLevelChange: onSoundLevelChange,
      listenOptions: SpeechListenOptions(
        onDevice: _onDevice,
        listenMode: ListenMode.confirmation,
        partialResults: true,
        autoPunctuation: true,
      ),
    );
  }

  void stopListening() {
    _speech.stop();
  }

  void cancelListening() {
    _speech.cancel();
  }

  void switchLogging(bool val) {
    _logEvents = val;
  }

  void switchOnDevice(bool val) {
    _onDevice = val;
  }

  void logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('$eventTime $eventDescription');
    }
  }

  void switchLanguage(String selectedVal) {
    _currentLocaleId = selectedVal;
  }
}





// import 'dart:async';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_recognition_error.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// class SpeechService {
//   final SpeechToText _speech = SpeechToText();

//   final bool _logEvents = false;
//   final bool _onDevice = false;

//   final List<LocaleName> _localeNames = [];
//   final String _currentLocaleId = '';
//   bool get hasSpeech => _hasSpeech;
//   bool _hasSpeech = false;

//   String lastWords = '';
//   String lastError = '';
//   String lastStatus = '';

//   double level = 0.0;
//   double minSoundLevel = 50000;
//   double maxSoundLevel = -50000;

//   List<LocaleName> get localeNames => _localeNames;
//   String get currentLocaleId => _currentLocaleId;

//   bool get isListening => _speech.isListening;

//   Future<void> initSpeechState(Function(String) onError) async {
//     try {
//       _hasSpeech = await _speech.initialize(
//         onError: (error) => onError(error.errorMsg),
//         onStatus: (status) => _logEvent('Status: $status'),
//         debugLogging: _logEvents,
//       );

//       if (_hasSpeech) {
//         _localeNames = await _speech.locales();
//         var systemLocale = await _speech.systemLocale();
//         _currentLocaleId = systemLocale?.localeId ?? '';
//       }
//     } catch (e) {
//       lastError = 'Speech recognition initialization failed: $e';
//     }
//   }

//   void startListening({
//     required Function(SpeechRecognitionResult) onResult,
//     required Function(double) onSoundLevelChange,
//     required String localeId,
//     required int pauseFor,
//     required int listenFor,
//   }) {
//     // _logEvent('start listening');
//     // lastWords = '';
//     // lastError = '';
//     // final pauseFor = int.tryParse(_pauseForController.text);
//     // final listenFor = int.tryParse(_listenForController.text);
//     // final options = SpeechListenOptions(onDevice: _onDevice, listenMode: ListenMode.confirmation, cancelOnError: true, partialResults: true, autoPunctuation: true, enableHapticFeedback: true);

//     {
//       speech.listen(
//         onResult: onResult,
//         listenFor: Duration(seconds: listenFor ?? 30),
//         pauseFor: Duration(seconds: pauseFor ?? 3),
//         localeId: _currentLocaleId,
//         onSoundLevelChange: onSoundLevelChange,
//         listenOptions: SpeechListenOptions(
//           onDevice: onDevice,
//           listenMode: ListenMode.confirmation,
//           cancelOnError: true,
//           partialResults: true,
//           autoPunctuation: true,
//           enableHapticFeedback: true,
//         ),
//       );
//     }
//   }

//   void stopListening() {
//     _logEvent('stop');
//     speech.stop();
//     setState(() {
//       level = 0.0;
//     });
//   }

//   void cancelListening() {
//     _logEvent('cancel');
//     speech.cancel();
//     setState(() {
//       level = 0.0;
//     });
//   }
// }

// class SttExample {
//   static Future<void> startListening() async {
//     // await initiallize();
//   }

//   void startListening() {
//     _logEvent('start listening');
//     lastWords = '';
//     lastError = '';
//     final pauseFor = int.tryParse(_pauseForController.text);
//     final listenFor = int.tryParse(_listenForController.text);
//     final options = SpeechListenOptions(onDevice: _onDevice, listenMode: ListenMode.confirmation, cancelOnError: true, partialResults: true, autoPunctuation: true, enableHapticFeedback: true);

//     speech.listen(
//       onResult: resultListener,
//       listenFor: Duration(seconds: listenFor ?? 30),
//       pauseFor: Duration(seconds: pauseFor ?? 3),
//       localeId: _currentLocaleId,
//       onSoundLevelChange: soundLevelListener,
//       listenOptions: options,
//     );
//     setState(() {});
//   }

//   void stopListening() {
//     _logEvent('stop');
//     speech.stop();
//     setState(() {
//       level = 0.0;
//     });
//   }

//   void cancelListening() {
//     _logEvent('cancel');
//     speech.cancel();
//     setState(() {
//       level = 0.0;
//     });
//   }

//   void resultListener(SpeechRecognitionResult result) {
//     _logEvent('Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
//     setState(() {
//       lastWords = '${result.recognizedWords} - ${result.finalResult}';
//     });
//   }

//   void soundLevelListener(double level) {
//     minSoundLevel = min(minSoundLevel, level);
//     maxSoundLevel = max(maxSoundLevel, level);

//     setState(() {
//       this.level = level;
//     });
//   }

//   void errorListener(SpeechRecognitionError error) {
//     _logEvent('Received error status: $error, listening: ${speech.isListening}');
//     setState(() {
//       lastError = '${error.errorMsg} - ${error.permanent}';
//     });
//   }

//   void statusListener(String status) {
//     _logEvent('Received listener status: $status, listening: ${speech.isListening}');
//     setState(() {
//       lastStatus = status;
//     });
//   }

//   void _switchLang(selectedVal) {
//     setState(() {
//       _currentLocaleId = selectedVal;
//     });
//     debugPrint(selectedVal);
//   }

//   void _logEvent(String eventDescription) {
//     if (_logEvents) {
//       var eventTime = DateTime.now().toIso8601String();
//       debugPrint('$eventTime $eventDescription');
//     }
//   }

//   void logEvent(String eventDescription) {
//     if (_logEvents) {
//       var eventTime = DateTime.now().toIso8601String();
//       print('$eventTime $eventDescription');
//     }
//   }

//   void _switchLogging(bool? val) {
//     setState(() {
//       _logEvents = val ?? false;
//     });
//   }

//   void _switchOnDevice(bool? val) {
//     setState(() {
//       _onDevice = val ?? false;
//     });
//   }
// }
