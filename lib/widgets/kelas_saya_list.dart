import 'package:flutter/material.dart';

import '../materi_pelatihan_screen.dart';
import '../tugas_saya_screen.dart';

class KelasSayaList extends StatelessWidget {
  const KelasSayaList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildKelasItem(context, 'Materi Pelatihan', '10% | Menunggu Konfirmasi Admin | Pendaftaran'),
        _buildKelasItem(context, 'Tugas', '80% | Lulus | Pelatihan'),
      ],
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
        } else if (title == 'Tugas') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TugasSayaScreen()),
          );
        }
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