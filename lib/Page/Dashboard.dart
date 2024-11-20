// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'Appbar.dart';
import 'ListTipeUjian.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Tambahkan GlobalKey di sini
      appBar: CustomAppBar(
        title: 'Dashboard',
        onNotificationPressed: () {
          // Aksi ketika notifikasi ditekan
          print('Notifikasi ditekan');
        },
      ),
      drawer: const CustomDrawer(), // Gunakan CustomDrawer di sini
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian pertama: Card untuk menu
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Bagian pertama: Card untuk menu
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    'Kuis',
                    Icons.quiz,
                    Colors.blue.withOpacity(0.2),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListTipeUjian(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Ulangan Harian',
                    Icons.note,
                    Colors.pink.withOpacity(0.2),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ListTipeUjian(), // Ganti dengan halaman tujuan Anda
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Ujian Tengah Semester',
                    Icons.school,
                    Colors.greenAccent.withOpacity(0.2),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ListTipeUjian(), // Ganti dengan halaman tujuan Anda
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    'Ujian Akhir Semester',
                    Icons.book,
                    Colors.amber.withOpacity(0.2),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ListTipeUjian(), // Ganti dengan halaman tujuan Anda
                        ),
                      );
                    },
                  ),
                ],
              )
            ]),

            const SizedBox(height: 20),

            // Bagian kedua: Laporan Total Kehadiran
            const Text(
              'Laporan Total Kehadiran',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200, // Grafik placeholder
              color: Colors.grey[300],
              child: const Center(child: Text('Grafik Kehadiran')),
            ),
            const SizedBox(height: 20),

            // Bagian ketiga: Progres Kehadiran
            const Center(
              child: Column(
                children: [
                  Text(
                    '90%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text('Hadir dari seluruh jadwal terdaftar'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bagian keempat: Bank Soal
            _buildSectionTitle('Bank Soal'),
            _buildBankSoalItem(
                'Kisi-kisi materi Pemodelan Linear dan Variabel'),
            _buildBankSoalItem(
                'Kisi-kisi materi Pemodelan Non-Linear dan Variabel'),
            const SizedBox(height: 20),

            // Bagian kelima: Kalender
            _buildSectionTitle('Agustus 2024'),
            Container(
              height: 300, // Placeholder kalender
              color: Colors.grey[300],
              child: const Center(child: Text('Kalender Placeholder')),
            ),
            const SizedBox(height: 20),

            // Bagian keenam: Jadwal Ujian
            _buildSectionTitle('Jadwal Ujian'),
            _buildJadwalUjianItem(
                '8 Agustus 2024', 'Pemodelan Linear dan Variabel'),
            _buildJadwalUjianItem(
                '10 Agustus 2024', 'Pemodelan Non-Linear dan Variabel'),
            const SizedBox(height: 20),

            // Bagian ketujuh: Notifikasi
            _buildSectionTitle('Notifikasi'),
            _buildNotificationItem(
                'Masuk ke Absen', '8 Agustus 2024 - Harap isi absen'),
            _buildNotificationItem(
                'Masuk ke Data', '10 Agustus 2024 - Harap lengkapi data Anda'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 3,
            child: Container(
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.width / 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color.withOpacity(1), size: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _buildBankSoalItem(String title) {
    return ListTile(
      leading: const Icon(Icons.file_copy, color: Colors.blue),
      title: Text(title),
      trailing: ElevatedButton(
        onPressed: () {},
        child: const Text('Preview'),
      ),
    );
  }

  Widget _buildJadwalUjianItem(String date, String title) {
    return ListTile(
      leading: const Icon(Icons.event, color: Colors.green),
      title: Text('$date - $title'),
      trailing: ElevatedButton(
        onPressed: () {},
        child: const Text('Mulai'),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.notifications, color: Colors.orange),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
