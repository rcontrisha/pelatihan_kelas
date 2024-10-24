import 'package:flutter/material.dart';
import 'package:pelatihan_kelas/modules/Beranda/informasi_pelatihan_pengajar_screen.dart';
import 'package:pelatihan_kelas/modules/Beranda/informasi_pelatihan_screen.dart';
import 'package:pelatihan_kelas/services/api_services.dart';

class LoginController {
  final ApiService apiService = ApiService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Fungsi untuk menangani proses login
  Future<void> login(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar(context, 'Email dan password harus diisi');
      return;
    }

    final result = await apiService.login(email, password);

    if (result != null) {
      // Memeriksa role pengguna
      final role =
          result['role']; // Asumsikan API mengembalikan 'role' dalam respons

      if (role == 'user') {
        // Jika role adalah 'user', navigasi ke halaman InformasiPelatihanScreen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const InformasiPelatihanScreen()),
        );
      } else if (role == 'pengajar') {
        // Jika role adalah 'pengajar', navigasi ke halaman InformasiPelatihanPengajarScreen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const InformasiPelatihanPengajarScreen()),
        );
      } else {
        _showSnackbar(context, 'Peran pengguna tidak dikenali.');
      }
    } else {
      // Jika login gagal, tampilkan pesan error
      _showSnackbar(context, 'Login gagal. Periksa kredensial Anda.');
    }
  }

  // Fungsi untuk menampilkan pesan snackbar
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Bersihkan input setelah digunakan
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
