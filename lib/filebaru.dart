import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kuis"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
          const CircleAvatar(
            backgroundImage: NetworkImage(
                "https://randomuser.me/api/portraits/women/44.jpg"), // Foto Profil
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const Drawer(),
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
                fillColor: Color(0xFFF2F2F2),
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Row(
              children: [
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
                const Spacer(),
                Text(
                  "$questionCount Soal",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Text("${(progress * 100).toInt()}%"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  "8 Agustus 2024",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(buttonText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
