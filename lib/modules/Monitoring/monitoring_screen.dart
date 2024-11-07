import 'package:flutter/material.dart';
import 'package:pelatihan_kelas/modules/Akun/akun_screen.dart';
import 'package:pelatihan_kelas/modules/Beranda/informasi_pelatihan_screen.dart';
import 'package:pelatihan_kelas/modules/Layanan/layanan_screen.dart';
import 'package:pelatihan_kelas/modules/Monitoring/kelas_saya_screen.dart';
import 'package:pelatihan_kelas/services/api_services.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final ApiService apiService = ApiService(); // Instance API service
  late Future<List<dynamic>?> _daftarPelatihan;
  int _selectedTabIndex = 1; // Menyimpan index dari tab yang dipilih

  @override
  void initState() {
    super.initState();
    // Ambil daftar pelatihan yang diikuti pengguna
    _daftarPelatihan = apiService.getUserTrainings();
  }

  String baseUrl =
      'http://192.168.1.11:8000/storage/'; // Ganti dengan URL basis API Anda

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pastikan Scaffold membungkus FutureBuilder
      appBar: AppBar(
        title: const Text('Monitoring Pelatihan'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton('Beranda', 0),
                _buildTabButton('Monitoring', 1),
                _buildTabButton('Akun', 2),
                _buildTabButton('Layanan', 3),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              // Letakkan FutureBuilder di dalam body Scaffold
              future: _daftarPelatihan,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada pelatihan.'));
                } else {
                  final pelatihans = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pelatihans.length,
                    itemBuilder: (context, index) {
                      final pelatihan = pelatihans[index];
                      return _buildKelasItem(
                          context,
                          pelatihan['pelatihan']['nama'] ?? 'Nama Pelatihan',
                          '${pelatihan['pelatihan']['deskripsi'] ?? 'Deskripsi tidak tersedia'}',
                          pelatihan['pelatihan']['id'], // ID pelatihan
                          '$baseUrl${pelatihan['pelatihan']['foto_pelatihan'] ?? ''}');
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelasItem(BuildContext context, String title, String subtitle,
      int pelatihanId, String fotoUrl) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail atau materi pelatihan dengan pelatihanId
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => KelasSayaScreen(pelatihanId: pelatihanId)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 150,
                child: Image.network(
                  fotoUrl, // Menggabungkan basis URL dengan foto_url
                  fit: BoxFit.cover, // Agar gambar memenuhi kontainer
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Gambar tidak tersedia'));
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membangun tombol tab
  Widget _buildTabButton(String text, int index) {
    bool isActive = _selectedTabIndex == index; // Cek apakah tab ini aktif

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index; // Ubah tab yang aktif
        });

        // Aksi ketika tab di-klik berdasarkan index
        if (index == 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const InformasiPelatihanScreen()));
        } else if (index == 1) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MonitoringScreen()));
        } else if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AkunScreen()));
        } else if (index == 3) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const InformasiLayananScreen()));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
