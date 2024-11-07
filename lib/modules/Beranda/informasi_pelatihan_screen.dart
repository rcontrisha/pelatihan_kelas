import 'package:flutter/material.dart';
import 'package:pelatihan_kelas/services/api_services.dart';
import '../Detail Pelatihan/detail_pelatihan_screen.dart';
import '../Akun/akun_screen.dart';
import '../Monitoring/monitoring_screen.dart';
import '../Layanan/layanan_screen.dart';

class InformasiPelatihanScreen extends StatefulWidget {
  const InformasiPelatihanScreen({Key? key}) : super(key: key);

  @override
  _InformasiPelatihanScreenState createState() =>
      _InformasiPelatihanScreenState();
}

class _InformasiPelatihanScreenState extends State<InformasiPelatihanScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>?>
      _pelatihans; // Future untuk menampung data pelatihan

  String baseUrl =
      'http://192.168.1.11:8000/storage/'; // Ganti dengan URL basis API Anda

  @override
  void initState() {
    super.initState();
    // Ambil data pelatihan dari API
    _pelatihans = apiService.getPelatihans();
  }

  int _selectedTabIndex = 0; // Menyimpan index dari tab yang dipilih

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Pelatihan'),
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
          // Menggunakan FutureBuilder untuk memuat data pelatihan
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: _pelatihans,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Jika data sedang diambil, tampilkan loading indicator
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Jika ada error saat mengambil data
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  // Jika data berhasil diambil, tampilkan daftar pelatihan
                  final pelatihans = snapshot.data!;
                  return ListView.builder(
                    itemCount: pelatihans.length,
                    itemBuilder: (context, index) {
                      final pelatihan = pelatihans[index];
                      return _buildPelatihanItem(context, pelatihan);
                    },
                  );
                } else {
                  // Jika data kosong
                  return const Center(child: Text('Tidak ada data pelatihan.'));
                }
              },
            ),
          ),
        ],
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

  // Fungsi untuk membangun item pelatihan dari data API
  Widget _buildPelatihanItem(BuildContext context, dynamic pelatihan) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DetailPelatihanScreen(pelatihanId: pelatihan['id'])),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                child: Image.network(
                  '$baseUrl${pelatihan['foto_pelatihan'] ?? ''}', // Menggabungkan basis URL dengan foto_url
                  fit: BoxFit.cover, // Agar gambar memenuhi kontainer
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Gambar tidak tersedia'));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pelatihan['nama'] ?? 'Nama Pelatihan',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(pelatihan['deskripsi'] ?? 'Deskripsi Pelatihan'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
