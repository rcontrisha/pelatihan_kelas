import 'package:flutter/material.dart';
import 'package:pelatihan_kelas/modules/Akun/akun_screen.dart';
import 'package:pelatihan_kelas/modules/Beranda/informasi_pelatihan_screen.dart';
import 'package:pelatihan_kelas/modules/Monitoring/monitoring_screen.dart';

class InformasiLayananScreen extends StatefulWidget {
  const InformasiLayananScreen({Key? key}) : super(key: key);

  @override
  State<InformasiLayananScreen> createState() => _InformasiLayananScreenState();
}

class _InformasiLayananScreenState extends State<InformasiLayananScreen> {
  int _selectedTabIndex = 3; // Menyimpan index dari tab yang dipilih

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Layanan'),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  // Menu layanan dengan dummy data
                  _buildDropdownService('LEMBAGA',
                      'Informasi tentang lembaga kami yang berdedikasi untuk pendidikan dan pelatihan.'),
                  _buildDropdownService('KERJA SAMA',
                      'Kerja sama dengan berbagai pihak untuk meningkatkan kualitas pelatihan.'),
                  _buildDropdownService('JADWAL',
                      'Jadwal pelatihan yang akan datang dan jadwal seminar yang sudah disusun.'),
                  _buildDropdownService('DOKUMENTASI',
                      'Dokumentasi kegiatan pelatihan sebelumnya termasuk foto dan video.'),
                  _buildDropdownService('KELUHAN',
                      'Bagian keluhan untuk melaporkan masalah atau pertanyaan terkait layanan kami.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membuat widget ExpansionTile (Dropdown)
  Widget _buildDropdownService(String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ExpansionTile(
          title: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
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
