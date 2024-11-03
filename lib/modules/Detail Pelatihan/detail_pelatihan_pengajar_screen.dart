import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pelatihan_kelas/modules/Detail%20Pelatihan/daftar_peserta_screen.dart';
import 'package:pelatihan_kelas/services/api_services.dart';

class DetailPelatihanPengajarScreen extends StatefulWidget {
  final int pelatihanId;

  const DetailPelatihanPengajarScreen({Key? key, required this.pelatihanId})
      : super(key: key);

  @override
  _DetailPelatihanPengajarScreenState createState() =>
      _DetailPelatihanPengajarScreenState();
}

class _DetailPelatihanPengajarScreenState
    extends State<DetailPelatihanPengajarScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>?> _pelatihanDetail;

  String baseUrl =
      'http://192.168.153.163:8000/storage/'; // Ganti dengan URL basis API Anda

  @override
  void initState() {
    super.initState();
    // Mengambil data detail pelatihan berdasarkan ID
    _pelatihanDetail = apiService.getPelatihanDetail(widget.pelatihanId);
  }

  String formatTanggal(String? dateString) {
    if (dateString == null) return '';
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMMM y').format(date);
  }

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
                        '$baseUrl${pelatihan['foto_pelatihan'] ?? ''}',
                        fit: BoxFit.cover,
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
                  ],
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Arahkan ke halaman daftar peserta pelatihan
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PesertaPelatihanScreen(pelatihanId: widget.pelatihanId),
            ),
          );
        },
        child: const Icon(Icons.people),
      ),
    );
  }

  // Fungsi untuk membangun item detail pelatihan menggunakan Container
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
