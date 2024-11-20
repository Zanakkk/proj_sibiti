// ignore_for_file: empty_catches, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import 'HomePage.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class SafeExamPage extends StatefulWidget {
  const SafeExamPage({required this.link, super.key});

  final String link;

  @override
  _SafeExamPageState createState() => _SafeExamPageState();
}

class _SafeExamPageState extends State<SafeExamPage>
    with WidgetsBindingObserver {
  late final WebViewController controller;
  bool _isLoading = false; // Menandakan proses submit sedang berlangsung

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // Mendaftarkan observer lifecycle

    _enableKioskMode();

    // Initialize WebViewController
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Inject JavaScript untuk menonaktifkan seleksi teks dan copy-paste
            controller.runJavaScript("""
              document.body.style.userSelect = 'none';
              document.body.style.webkitUserSelect = 'none';
              document.body.style.msUserSelect = 'none';
              document.body.style.pointerEvents = 'auto';
              window.getSelection().removeAllRanges();
            """);
          },
          onNavigationRequest: (NavigationRequest request) {
            // Blokir navigasi ke URL tertentu jika diperlukan
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.link));
  }

  /// Mengaktifkan mode kiosk
  Future<void> _enableKioskMode() async {
    try {
      await startKioskMode();
    } catch (e) {
      _showErrorMessage('Failed to start kiosk mode: $e');
    }
  }

  /// Menonaktifkan mode kiosk
  Future<void> _disableKioskMode() async {
    try {
      await stopKioskMode();
    } catch (e) {
      _showErrorMessage('Failed to stop kiosk mode: $e');
    }
  }

  /// Dialog Exit dengan Validasi Password
  Future<void> _showExitPasswordDialog(String exitCode) async {
    const String url = 'https://sibiti-smansa-prodlike.my.id/api/seb-exam/exit';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'exitCode': exitCode}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['data']?['isExit'] == true) {
          await _disableKioskMode(); // Hentikan mode kiosk

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          _showErrorMessage('Invalid EXITCODE');
        }
      } else {
        _showErrorMessage('Failed to validate EXITCODE');
      }
    } catch (e) {
      _showErrorMessage('An error occurred while validating EXITCODE');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Tampilkan Pesan Error
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _showErrorMessage('You cannot exit exam mode.');
          return false; // Blokir aksi tombol back
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('SIBITI', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: const Color(0xFF004AAD),
            elevation: 4,
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                onPressed: () {
                  final TextEditingController passwordController =
                      TextEditingController();

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Enter EXITCODE'),
                        content: TextField(
                          controller: passwordController,
                          decoration:
                              const InputDecoration(hintText: 'EXITCODE'),
                        ),
                        actions: [
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            TextButton(
                              onPressed: () {
                                String enteredPassword =
                                    passwordController.text;
                                _showExitPasswordDialog(enteredPassword);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Submit'),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: WebViewWidget(controller: controller),
        ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Hapus observer
    super.dispose();
  }
}
