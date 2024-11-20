// ignore_for_file: empty_catches, unused_catch_clause, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

class WindowsSafeExamPage extends StatefulWidget {
  const WindowsSafeExamPage({super.key});

  @override
  _WindowsSafeExamPageState createState() => _WindowsSafeExamPageState();
}

class _WindowsSafeExamPageState extends State<WindowsSafeExamPage>
    with WindowListener {
  final WebviewController _webViewController = WebviewController();
  bool _isWebviewInitialized = false;

  static const MethodChannel _lockTaskChannel =
      MethodChannel('proj.seb.sibiti/locktask');

  @override
  void initState() {
    super.initState();
    _initializeWindow();
    _initializeWebView();
    _startLockTask();
  }

  // Start Lock Task Mode
  Future<void> _startLockTask() async {
    try {
      await _lockTaskChannel.invokeMethod('startLockTask');
    } on PlatformException catch (e) {}
  }

  // Stop Lock Task Mode
  Future<void> _stopLockTask() async {
    try {
      await _lockTaskChannel.invokeMethod('stopLockTask');
    } on PlatformException catch (e) {}
  }

  // Initialize Window and Full-Screen Mode
  Future<void> _initializeWindow() async {
    await windowManager.ensureInitialized();
    windowManager.addListener(this);

    // Set to full screen
    await windowManager.setFullScreen(true);
  }

  // Initialize WebView
  Future<void> _initializeWebView() async {
    try {
      await _webViewController.initialize();
      await _webViewController.loadUrl('https://sibiti-smansa.my.id/');
      await _webViewController
          .setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

      setState(() {
        _isWebviewInitialized = true;
      });
    } on PlatformException catch (e) {
      _showErrorDialog('Error initializing WebView', e.message);
    }
  }

  // Show error dialog if something goes wrong
  void _showErrorDialog(String title, String? message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Message: $message'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    windowManager.setFullScreen(false); // Exit full screen mode
    _webViewController.dispose();

    _stopLockTask();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Exam Browser'),
        actions: [
          IconButton(
            onPressed: () {
              _showPasswordDialog(context);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: _isWebviewInitialized
            ? Webview(
                _webViewController,
                permissionRequested: _onPermissionRequested,
              )
            : const Text('Loading WebView...', style: TextStyle(fontSize: 24)),
      ),
    );
  }

  // Handle WebView permissions
  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WebView permission requested'),
        content: Text('WebView has requested permission for \'$kind\''),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    return decision ?? WebviewPermissionDecision.none;
  }

  // Show password dialog for unlocking
  void _showPasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (passwordController.text == "1234") {
                  _stopLockTask();
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog('Incorrect Password', 'Please try again.');
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
