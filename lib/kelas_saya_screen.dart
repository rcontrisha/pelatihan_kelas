import 'package:flutter/material.dart';
import 'materi_pelatihan_screen.dart';

class KelasSayaScreen extends StatelessWidget {
  const KelasSayaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelas Saya'),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildKelasItem(context, 'Materi Pelatihan', '10% | Menunggu Konfirmasi Admin | Pendaftaran'),
                _buildKelasItem(context, 'Tugas', '80% | Lulus | Pelatihan'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabButton('Beranda', false),
          _buildTabButton('Monitoring', true),
          _buildTabButton('Akun', false),
          _buildTabButton('Layanan', false),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return Container(
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
    );
  }

  Widget _buildKelasItem(BuildContext context, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        if (title == 'Materi Pelatihan') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MateriPelatihanScreen()),
          );
        }
        // Add navigation for 'Tugas' if needed
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
                color: Colors.grey[300],
                child: const Center(child: Text('Foto')),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}