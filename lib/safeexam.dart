// ignore_for_file: empty_catches, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import 'HomePage.dart';

class SafeExamPage extends StatefulWidget {
  const SafeExamPage({required this.link, super.key});

  final String link;

  @override
  _SafeExamPageState createState() => _SafeExamPageState();
}

class _SafeExamPageState extends State<SafeExamPage>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  static const MethodChannel _lockTaskChannel =
      MethodChannel('proj.seb.sibiti/locktask');
  static const MethodChannel _audioChannel =
      MethodChannel('proj.seb.sibiti/audio');
  bool _isLoading = false;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableLockTaskMode();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _controller.runJavaScript("""
              document.body.style.userSelect = 'none';
              document.body.style.webkitUserSelect = 'none';
              document.body.style.msUserSelect = 'none';
              window.getSelection()?.removeAllRanges();
            """);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.link));
  }

  Future<void> _enableLockTaskMode() async {
    try {
      await _lockTaskChannel.invokeMethod('startLockTask');
    } on PlatformException catch (e) {
      debugPrint('Failed to enable lock task mode: $e');
    }
  }

  Future<void> _disableLockTaskMode() async {
    try {
      await _lockTaskChannel.invokeMethod('stopLockTask');
    } on PlatformException catch (e) {
      debugPrint('Failed to disable lock task mode: $e');
    }
  }

  static const platformAudio = MethodChannel('proj.seb.sibiti/audio');

  Future<void> _playSound() async {
    try {
      // Atur audio ke speaker sebelum memutar suara
      await platformAudio.invokeMethod('playThroughSpeaker');

      // Mainkan audio
      final audioPlayer = AudioPlayer();
      await audioPlayer.play(AssetSource('alarm.wav'));
    } catch (e) {
      print('Failed to set audio output: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isExiting &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive ||
            state == AppLifecycleState.detached)) {
      _playSound();
      _forceAppRestart();
    }
  }


  Future<void> _forceAppRestart() async {
    await _enableLockTaskMode();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => SafeExamPage(link: widget.link)),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _showExitDialog(String exitCode) async {
    const String apiUrl = 'https://sibiti-smansa.my.id/api/seb-exam/exit';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'exitCode': exitCode}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['data']?['isExit'] == true) {
          _isExiting = true; // Tambahkan flag exit di sini
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }

          await _disableLockTaskMode();
        } else {
          _showErrorSnackBar('Invalid EXITCODE.');
        }
      } else {
        _showErrorSnackBar('Failed to validate EXITCODE.');
      }
    } catch (e) {
      _showErrorSnackBar('Error occurred while validating EXITCODE.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showErrorSnackBar('You cannot exit exam mode.');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SIBITI', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF004AAD),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () {
                final TextEditingController exitCodeController =
                    TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Enter EXITCODE'),
                    content: TextField(
                      controller: exitCodeController,
                      decoration: const InputDecoration(hintText: 'EXITCODE'),
                    ),
                    actions: [
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        TextButton(
                          onPressed: () {
                            final exitCode = exitCodeController.text;
                            Navigator.pop(context);
                            _showExitDialog(exitCode);
                          },
                          child: const Text('Submit'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
