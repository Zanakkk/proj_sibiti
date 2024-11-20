// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';

import '../Exam/Exam.dart';
import 'Appbar.dart';

class PeraturanUjian extends StatelessWidget {
  const PeraturanUjian({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: 'UJIAN',
          onNotificationPressed: () {
            // Aksi ketika notifikasi ditekan
            print('Notifikasi ditekan');
          },
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi Kuis
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pertidaksamaan Linear Dua Variabel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Jumlah Soal',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.timer, color: Colors.blue, size: 32),
                          SizedBox(width: 8),
                          Text(
                            '01:45:00',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Peraturan Ujian
                    const Text(
                      'Peraturan Ujian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '''
1. Kehadiran Tepat Waktu: Peserta ujian harus hadir tepat waktu. Biasanya ada batas waktu kapan peserta boleh masuk ke ruang ujian setelah ujian dimulai.
2. Kelengkapan Alat Tulis: Peserta wajib membawa alat tulis sendiri, seperti pensil, pulpen, penghapus, dan kalkulator jika diperlukan. Biasanya tidak diperbolehkan untuk meminjam alat tulis selama ujian.
3. Kartu Identitas atau Kartu Ujian: Peserta harus membawa kartu identitas atau kartu ujian sebagai bukti bahwa mereka terdaftar untuk mengikuti ujian.
4. Dilarang Membawa Benda Terlarang: Perangkat elektronik seperti ponsel, tablet, smartwatch, atau bahan bacaan biasanya dilarang dibawa ke dalam ruang ujian. Ada juga aturan ketat mengenai menyontek atau menggunakan catatan.
5. Kedisiplinan dalam Ruang Ujian: Peserta harus menjaga ketenangan dan tidak boleh mengganggu peserta lain. Komunikasi antar peserta dilarang selama ujian berlangsung.
6. Pengaturan Waktu Ujian: Peserta diharapkan mematuhi waktu yang diberikan untuk menyelesaikan ujian. Biasanya, ada tanda peringatan sebelum waktu ujian berakhir.
7. Instruksi Pengawas Ujian: Peserta harus mengikuti semua instruksi dari pengawas ujian, termasuk ketika ujian dimulai dan berakhir, serta prosedur pengumpulan jawaban.
8. Larangan Mencontek: Mencontek atau membantu peserta lain selama ujian dianggap pelanggaran serius yang dapat berakibat pada diskualifikasi atau hukuman lain sesuai dengan kebijakan institusi.
              ''',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                      softWrap: true,
                    ),
                    const SizedBox(height: 24),

                    // Tombol Mulai
                  ],
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SubTestScreen(
                                testName: 'EXAM',
                                apiUrl:
                                    'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/DataBaru.json',
                                duration: 15,
                              )));
                  // Tambahkan logika navigasi ke halaman berikutnya
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: const Color(0xFF2881CF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Mulai',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ));
  }
}
