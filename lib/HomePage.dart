// ignore_for_file: use_build_context_synchronously, unused_catch_clause, empty_catches, library_private_types_in_public_api, unused_element, file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sibiti/safeexam.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('proj.seb.sibiti/locktask');
  final TextEditingController _controller = TextEditingController();

// Menandakan apakah sedang dalam proses submit
// To track if the exam is in lock mode

  Future<void> _stopLockTask() async {
    try {
      await platform.invokeMethod('stopLockTask');
    } on PlatformException catch (e) {}
  }

  Future<void> _startExam(String password) async {
    setState(() {});

    // API endpoint
    const String url =
        'https://sibiti-smansa-prodlike.my.id/api/seb-exam/start';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String link = responseData['link'];
        // Navigate to SafeExamPage with the link
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SafeExamPage(link: link),
          ),
        );
      } else {
        // You can show an error message if the API fails
      }
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Text(
            'SEB v1.0.2',
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            width: 12,
          )
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Title
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004AAD),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Safe Exam Browser',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004AAD),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'SIBITI',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004AAD),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 80),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56, // Tentukan tinggi yang sama
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Enter your Exam Code',
                            hintStyle:
                                TextStyle(color: Colors.black.withOpacity(0.6)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color(0xFF004AAD), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color(0xFF004AAD), width: 2),
                            ),
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 56, // Tinggi yang sama seperti TextField
                      child: ElevatedButton(
                        onPressed: () {
                          _startExam(_controller.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004AAD),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20), // Lebar tombol
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Submit',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF004AAD),
        foregroundColor: Colors.white,
        onPressed: _stopLockTask,
        // Menggunakan _stopLockTask untuk menonaktifkan Lock Task Mode
        child: const Icon(
          Icons.lock_open,
          color: Colors.white,
        ),
      ),
    );
  }
}
