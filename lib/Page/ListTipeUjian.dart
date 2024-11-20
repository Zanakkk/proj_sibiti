// ignore_for_file: file_names

import 'package:flutter/material.dart';

import 'Appbar.dart';
import 'PeraturanUjian.dart';

class ListTipeUjian extends StatelessWidget {
  const ListTipeUjian({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'UJIAN',
        onNotificationPressed: () {
          // Aksi ketika notifikasi ditekan
        },
      ),
      drawer: const CustomDrawer(), // Gunakan CustomDrawer di sini
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Cari kuis",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Kuis",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return QuizCard(
                    title: "Kuis Matematika",
                    description: "Pertidaksamaan Linear Dua Variabel",
                    status: index == 0
                        ? "Belum Dimulai"
                        : index == 1
                            ? "Selesai"
                            : "Sedang Berlangsung",
                    statusColor: index == 0
                        ? Colors.red
                        : index == 1
                            ? Colors.green
                            : Colors.orange,
                    buttonText: index == 0
                        ? "Mulai"
                        : index == 1
                            ? "Lihat Hasil"
                            : "Lanjutkan",
                    progress: index == 0
                        ? 0
                        : index == 1
                            ? 1
                            : 0.35 + (index * 0.01),
                    questionCount: index == 0
                        ? 0
                        : index == 1
                            ? 60
                            : 15,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizCard extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final Color statusColor;
  final String buttonText;
  final double progress;
  final int questionCount;

  const QuizCard({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.buttonText,
    required this.progress,
    required this.questionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul dan Deskripsi
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 8),

                  // Status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Jumlah Soal

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$questionCount Soal",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text("${(progress * 100).toInt()}%"),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Progress
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 8),

                            // Tanggal dan Tombol
                            const Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  "8 Agustus 2024",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                Spacer(),
                                Icon(Icons.watch_later_outlined,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  "08.30",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PeraturanUjian()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2881CF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // Atur seberapa melengkung tepiannya
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
