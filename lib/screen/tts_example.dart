import 'package:flutter/material.dart';
import 'package:hdx_tests/service/tts_example.dart';

class TtsSampleApp extends StatefulWidget {
  const TtsSampleApp({super.key});

  @override
  State<TtsSampleApp> createState() => _TtsSampleAppState();
}

class _TtsSampleAppState extends State<TtsSampleApp> {
  final TtsService ttsService = TtsService();

  @override
  void dispose() {
    super.dispose();
    ttsService.dispose();
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
          title: const Text('TTS Example'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              // inputSection,
              Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
                child: TextField(
                  maxLines: 6,
                  minLines: 3,
                  onChanged: ttsService.setVoiceText,
                ),
              ),
              // buttonSection,
              Container(
                padding: const EdgeInsets.only(top: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => ttsService.speak(),
                      child: const Text(
                        'PLAY',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => ttsService.stop(),
                      child: const Text(
                        'STOP',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => ttsService.pause(),
                      child: const Text(
                        'PAUSE',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              // engineSection,
              FutureBuilder<dynamic>(
                future: ttsService.getEngines(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return DropdownButton<String>(
                      value: ttsService.engine,
                      items: (snapshot.data as List<dynamic>)
                          .map((engine) => DropdownMenuItem(
                                value: engine as String,
                                child: Text(engine),
                              ))
                          .toList(),
                      // onChanged: ttsService.changedEngines,
                      onChanged: (String? newEngine) {
                        ttsService.changedEngines(newEngine);
                        setState(() {
                          ttsService.engine = newEngine;
                        });
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              // languageSection,
              FutureBuilder<dynamic>(
                future: ttsService.getLanguages(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return DropdownButton<String>(
                      value: ttsService.language,
                      items: (snapshot.data as List<dynamic>)
                          .map((language) => DropdownMenuItem(
                                value: language as String,
                                child: Text(language),
                              ))
                          .toList(),
                      // onChanged: ttsService.changedLanguage,
                      onChanged: (String? newLanguage) {
                        ttsService.changedLanguage(newLanguage);
                        setState(() {
                          ttsService.language = newLanguage;
                        });
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              // buildSliders,
              Slider(
                value: ttsService.speechRate,
                onChanged: (newRate) {
                  setState(() => ttsService.speechRate = newRate);
                },
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: "Rate: ${ttsService.speechRate.toStringAsFixed(1)}",
                activeColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
