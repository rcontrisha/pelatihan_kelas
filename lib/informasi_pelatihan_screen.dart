import 'package:flutter/material.dart';
import 'package:pelatihan_kelas/akun_screen.dart';
import 'package:pelatihan_kelas/layanan_screen.dart';
import 'package:pelatihan_kelas/monitoring_screen.dart';
import 'detail_pelatihan_screen.dart';
import 'kelas_saya_screen.dart';

class InformasiPelatihanScreen extends StatefulWidget {
  const InformasiPelatihanScreen({Key? key}) : super(key: key);

  @override
  _InformasiPelatihanScreenState createState() => _InformasiPelatihanScreenState();
}

class _InformasiPelatihanScreenState extends State<InformasiPelatihanScreen> {
  int _selectedTabIndex = 0; // Menyimpan index dari tab yang dipilih

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Pelatihan'),
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
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildPelatihanItem(context);
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const InformasiPelatihanScreen()));
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MonitoringScreen()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AkunScreen()));
        }else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const InformasiLayananScreen()));
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

  Widget _buildPelatihanItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetailPelatihanScreen()),
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
                color: Colors.grey[300],
                child: const Center(child: Text('Foto Pelatihan')),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Nama Pelatihan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('Deskripsi Pelatihan'),
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
