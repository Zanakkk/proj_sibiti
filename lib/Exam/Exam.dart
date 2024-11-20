// ignore_for_file: file_names, use_build_ddcontext_synchronously, use_build_context_synchronously

import 'dart:async';
import 'dart:convert'; // Untuk mengolah JSON

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart'; // Tambahkan ini untuk merender HTML

class SubTestScreen extends StatefulWidget {
  final String testName;
  final String apiUrl;
  final int duration;

  const SubTestScreen({
    required this.testName,
    required this.apiUrl,
    required this.duration,
    super.key,
  });

  @override
  State<SubTestScreen> createState() => _SubTestScreenState();
}

class _SubTestScreenState extends State<SubTestScreen> {
  final PageController _pageController = PageController();
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];

  late Duration duration; // Gunakan late untuk menginisialisasi di initState
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    duration = Duration(minutes: widget.duration);
    startTimer();
  }

  Future<void> _loadQuestions() async {
    try {
      // Ambil data dari API menggunakan HTTP GET
      final response = await http.get(Uri.parse(widget.apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final questionData = data['question'];

        setState(() {
          questions = List<Map<String, dynamic>>.from(questionData.map((item) {
            return {
              'id': item['id'], // ID soal
              'question': item['question'], // Teks soal
              'answers': [
                item['A'],
                item['B'],
                item['C'],
                item['D'],
                item['E']
              ], // Jawaban
              'options': ['A', 'B', 'C', 'D', 'E'], // Label opsi
              'selectedAnswer': null, // Jawaban yang dipilih pengguna
              'isDoubtful': false, // Status ragu-ragu
            };
          }));

          // Urutkan soal berdasarkan ID
          questions.sort((a, b) => a['id'].compareTo(b['id']));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load questions: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (duration.inSeconds > 0) {
          duration = duration - const Duration(seconds: 1);
        } else {
          timer.cancel();
          _showTimeUpNotification();
        }
      });
    });
  }

  void _showTimeUpNotification() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent the user from dismissing the dialog
      builder: (context) {
        return AlertDialog(
          title: const Text('Waktu Habis'),
          content: const Text(
              'Waktu tes telah habis, kamu akan diarahkan kembali ke halaman sebelumnya.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context)
                    .pop(true); // Navigate back to the previous screen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String get formattedTime {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subtes ${widget.testName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                formattedTime,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(questions.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            _pageController.jumpToPage(index);
                            setState(() {
                              currentQuestionIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: currentQuestionIndex == index
                                  ? Colors.blue
                                  : questions[index]['isDoubtful']
                                      ? Colors.yellow
                                      : questions[index]['selectedAnswer'] !=
                                              null
                                          ? Colors.green
                                          : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: currentQuestionIndex == index
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          currentQuestionIndex = index;
                        });
                      },
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        return _buildQuestionCard(index);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      questions[currentQuestionIndex]['options'].length,
                      (optionIndex) {
                        String optionLabel = questions[currentQuestionIndex]
                            ['options'][optionIndex];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              questions[currentQuestionIndex]
                                  ['selectedAnswer'] = optionLabel;
                            });
                          },
                          child: Card(
                            shape: const CircleBorder(),
                            color: questions[currentQuestionIndex]
                                        ['selectedAnswer'] ==
                                    optionLabel
                                ? Colors.blue
                                : Colors.grey[200],
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                optionLabel,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: questions[currentQuestionIndex]
                                              ['selectedAnswer'] ==
                                          optionLabel
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Sebelumnya
                      ElevatedButton(
                        onPressed: currentQuestionIndex > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        child: const Text('Sebelumnya'),
                      ),
                      // Checkbox Ragu-Ragu
                      Row(
                        children: [
                          Checkbox(
                            value: questions[currentQuestionIndex]
                                ['isDoubtful'],
                            onChanged: (value) {
                              setState(() {
                                questions[currentQuestionIndex]['isDoubtful'] =
                                    value!;
                              });
                            },
                            activeColor: Colors.yellow,
                          ),
                          const Text('Ragu-Ragu'),
                        ],
                      ),
                      // Tombol Berikutnya atau Selesaikan Tes
                      ElevatedButton(
                        onPressed: () {
                          if (currentQuestionIndex < questions.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finishTest();
                          }
                        },
                        child: Text(currentQuestionIndex < questions.length - 1
                            ? 'Berikutnya'
                            : 'Selesaikan Tes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HtmlWidget(
            questions[index]['question'], // Render pertanyaan HTML
            textStyle: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(questions[index]['answers'].length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text(
                      '${questions[index]['options'][i]}. ',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: HtmlWidget(
                        questions[index]['answers'][i] ??
                            '', // Render jawaban HTML
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _finishTest() {
    List<int> unansweredQuestions = [];
    List<int> doubtfulQuestions = [];

    for (int i = 0; i < questions.length; i++) {
      if (questions[i]['selectedAnswer'] == null) {
        unansweredQuestions.add(i + 1);
      }
      if (questions[i]['isDoubtful'] == true) {
        doubtfulQuestions.add(i + 1);
      }
    }

    if (unansweredQuestions.isNotEmpty || doubtfulQuestions.isNotEmpty) {
      // Tampilkan dialog jika ada soal yang belum terjawab atau ragu-ragu
      _showIncompleteQuestionsDialog(unansweredQuestions, doubtfulQuestions);
    } else {
      // Tampilkan modal pop-up jika semua soal sudah terjawab
      _showSuccessModal();
    }
  }

  void _showIncompleteQuestionsDialog(
      List<int> unansweredQuestions, List<int> doubtfulQuestions) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Soal Belum Terisi dan Ragu-Ragu'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unansweredQuestions.isNotEmpty)
                  Text(
                      'Soal yang belum dijawab: ${unansweredQuestions.join(", ")}'),
                if (unansweredQuestions.isNotEmpty &&
                    doubtfulQuestions.isNotEmpty)
                  const SizedBox(height: 16),
                if (doubtfulQuestions.isNotEmpty)
                  Text(
                      'Soal yang masih ragu-ragu: ${doubtfulQuestions.join(", ")}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selamat!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 16),
              Text(
                'Anda telah berhasil menyelesaikan subtes ${widget.testName}.',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}
