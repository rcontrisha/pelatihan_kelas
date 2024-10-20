import 'package:flutter/material.dart';

class AkunScreen extends StatelessWidget {
  const AkunScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bagian foto profil
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Informasi Akun
            _buildInfoButton(context, 'Nama Lengkap'),
            _buildInfoButton(context, 'Alamat'),
            _buildInfoButton(context, 'Email'),
            _buildInfoButton(context, 'Password'),
            _buildInfoButton(context, 'Riwayat'),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuat tombol informasi akun
  Widget _buildInfoButton(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton(
        onPressed: () {
          // Aksi saat tombol ditekan, bisa diarahkan ke halaman detail
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
