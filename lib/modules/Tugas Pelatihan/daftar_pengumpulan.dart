import 'package:flutter/material.dart';
import 'package:pelatihan_kelas/services/api_services.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class PengumpulanTugasScreen extends StatefulWidget {
  final int tugasId;

  const PengumpulanTugasScreen({Key? key, required this.tugasId})
      : super(key: key);

  @override
  _PengumpulanTugasScreenState createState() => _PengumpulanTugasScreenState();
}

class _PengumpulanTugasScreenState extends State<PengumpulanTugasScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _pengumpulanList = [];

  @override
  void initState() {
    super.initState();
    _getPengumpulanTugas();
  }

  Future<void> _getPengumpulanTugas() async {
    final pengumpulanList =
    await _apiService.getPengumpulanTugas(widget.tugasId);
    if (pengumpulanList != null) {
      setState(() {
        _pengumpulanList = pengumpulanList;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data pengumpulan tugas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumpulan Tugas'),
      ),
      body: _pengumpulanList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pengumpulanList.length,
        itemBuilder: (context, index) {
          final pengumpulan = _pengumpulanList[index];
          return _buildPengumpulanItem(pengumpulan);
        },
      ),
    );
  }

  Widget _buildPengumpulanItem(Map<String, dynamic> pengumpulan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://yourdomain.com/${pengumpulan['profile']}'), // Gambar profil siswa
              radius: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pengumpulan['nama'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pengumpulan['email'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tugas: ${pengumpulan['original_name']}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanggal Pengumpulan: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(pengumpulan['tanggal_pengumpulan']))}',
                    style: const TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _downloadTugas(pengumpulan['download_link']);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Tugas'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadTugas(String downloadLink) {
    // Implementasikan logika download sesuai dengan platform (mobile atau web).
    // Contoh penggunaan url_launcher untuk mendownload file di mobile/web:
    // launch('https://yourdomain.com/$downloadLink');
  }
}
