import 'package:flutter/material.dart';
import 'package:hdx_tests/screen/stt_tts_app.dart';
import 'package:hdx_tests/screen/stt_example.dart';
import 'package:hdx_tests/screen/tts_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: "Flutter STT / TTS",
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("[ STT / TTS ]"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SpeechSampleApp(),
                      ),
                    );
                  },
                  child: const Text(
                    "stt_example",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TtsSampleApp(),
                      ),
                    );
                  },
                  child: const Text(
                    "tts_example",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SttTtsApp(),
                      ),
                    );
                  },
                  child: const Text(
                    "stt + tts",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
