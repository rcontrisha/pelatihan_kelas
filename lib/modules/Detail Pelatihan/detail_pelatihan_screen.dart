import 'package:flutter/material.dart';
import 'package:pelatihan_kelas/services/api_services.dart';
import 'package:intl/intl.dart'; // Import intl
import '../Pendaftaran Pelatihan/pendaftaran_screen.dart';

class DetailPelatihanScreen extends StatefulWidget {
  final int pelatihanId; // Menyimpan ID pelatihan yang dipilih

  const DetailPelatihanScreen({Key? key, required this.pelatihanId})
      : super(key: key);

  @override
  _DetailPelatihanScreenState createState() => _DetailPelatihanScreenState();
}

class _DetailPelatihanScreenState extends State<DetailPelatihanScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>?> _pelatihanDetail;
  late Future<List<dynamic>?> _cekPelatihan;
  bool _isRegistered = false; // Flag untuk mengecek apakah user sudah terdaftar

  @override
  void initState() {
    super.initState();
    // Mengambil data detail pelatihan berdasarkan ID
    _pelatihanDetail = apiService.getPelatihanDetail(widget.pelatihanId);
    _cekPelatihan = apiService.getUserTrainings();

    // Lakukan pengecekan apakah user sudah terdaftar di pelatihan
    _cekPelatihan.then((userTrainings) {
      if (userTrainings != null) {
        setState(() {
          // Cek apakah user sudah terdaftar di pelatihan ini
          _isRegistered = userTrainings.any(
              (training) => training['pelatihan_id'] == widget.pelatihanId);
        });
      }
    });
  }

  String formatTanggal(String? dateString) {
    if (dateString == null) return '';
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMMM y').format(date);
  }

  String baseUrl =
      'http://192.168.114.163:8000/storage/'; // Ganti dengan URL basis API Anda

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelatihan'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _pelatihanDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Tidak ada data pelatihan.'));
          } else {
            // Data berhasil diambil, menampilkan detail pelatihan
            final pelatihan = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      child: Image.network(
                        '$baseUrl${pelatihan['foto_pelatihan'] ?? ''}', // Menggabungkan basis URL dengan foto_url
                        fit: BoxFit.cover, // Agar gambar memenuhi kontainer
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                              child: Text('Gambar tidak tersedia'));
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pelatihan['nama'] ?? 'Nama Pelatihan',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailItem('Jadwal Pelatihan',
                        '${formatTanggal(pelatihan['tanggal_mulai'])} - ${formatTanggal(pelatihan['tanggal_selesai'])}'),
                    _buildDetailItem('Lama Pelatihan',
                        '${pelatihan['lama_pelatihan']?.toString() ?? ''} Hari'),
                    _buildDetailItem('Kuota Peserta',
                        '${pelatihan['kuota']?.toString() ?? '0'} Peserta'),
                    _buildDetailItem(
                        'Instruktur', pelatihan['instruktur'] ?? ''),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isRegistered
                          ? null // Jika user sudah terdaftar, tombol menjadi tidak aktif
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PendaftaranScreen(
                                        pelatihanId: widget.pelatihanId)),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        primary: _isRegistered
                            ? Colors.grey
                            : Colors.black, // Ubah warna berdasarkan status
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(_isRegistered
                          ? 'Anda telah mengikuti pelatihan ini.'
                          : 'Daftar'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Fungsi untuk membangun item detail pelatihan menggunakan Container
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: double.infinity, // Memastikan kontainer memenuhi lebar layar
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, // Untuk menjajarkan label dan nilai ke kiri
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(value),
          ],
        ),
      ),
    );
  }
}
