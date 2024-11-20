import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:sibiti/web.dart';
import 'HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Exam Browser',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          // Mengatur warna latar belakang
          primaryColor: const Color(0xFF004AAD),
          // Warna utama (opsional jika diperlukan)
          cardColor: Colors.white,
          hoverColor: const Color(0xFF0079FF),
          canvasColor: const Color(0xFF0060FF)),
      home: Platform.isAndroid ? const HomePage() : const WindowsSafeExamPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
