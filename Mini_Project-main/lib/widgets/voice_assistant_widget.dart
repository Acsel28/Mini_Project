import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistantWidget extends StatefulWidget {
  const VoiceAssistantWidget({Key? key}) : super(key: key);

  @override
  State<VoiceAssistantWidget> createState() => _VoiceAssistantWidgetState();
}

class _VoiceAssistantWidgetState extends State<VoiceAssistantWidget> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _speakGreeting() async {
    // Use a dummy calorie value
    await _flutterTts.speak(
      "Welcome! How are you? Your recommended calories for today are 1850. What's your diet for today?",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.record_voice_over, color: Theme.of(context).primaryColor, size: 32),
                const SizedBox(width: 10),
                Text(
                  'AI Voice Assistant',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _waveAnimation.value : 1.0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.greenAccent.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.green : Colors.grey,
                      size: 36,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              _text.isEmpty ? 'Tap the mic and speak...' : _text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.green : Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  icon: Icon(_isListening ? Icons.hearing : Icons.mic_none),
                  label: Text(_isListening ? 'Listening...' : 'Start Listening'),
                  onPressed: _listen,
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Greet Me'),
                  onPressed: _speakGreeting,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
