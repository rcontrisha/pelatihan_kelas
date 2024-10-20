import 'package:flutter/material.dart';

class InformasiLayananScreen extends StatelessWidget {
  const InformasiLayananScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Layanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Menu layanan
            _buildServiceButton('LEMBAGA'),
            _buildServiceButton('KERJA SAMA'),
            _buildServiceButton('JADWAL'),
            _buildServiceButton('DOKUMENTASI'),
            _buildServiceButton('KELUHAN'),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuat tombol layanan
  Widget _buildServiceButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton(
        onPressed: () {
          // Aksi ketika tombol ditekan
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
