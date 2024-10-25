import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pelatihan_kelas/modules/Beranda/informasi_pelatihan_pengajar_screen.dart';
import 'package:pelatihan_kelas/modules/Beranda/informasi_pelatihan_screen.dart';
import 'package:pelatihan_kelas/modules/Layanan/layanan_screen.dart';
import 'package:pelatihan_kelas/modules/Login/login_screen.dart';
import 'package:pelatihan_kelas/modules/Monitoring/monitoring_pengajar_screen.dart';
import 'package:pelatihan_kelas/modules/Monitoring/monitoring_screen.dart';
import 'package:pelatihan_kelas/services/api_services.dart';
import 'package:image_picker/image_picker.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({Key? key}) : super(key: key);

  @override
  _AkunScreenState createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  String baseUrl =
      'http://192.168.114.163:8000/storage/'; // Ganti dengan URL server Anda
  ApiService apiService = ApiService();
  Map<String, dynamic>? userProfile;
  XFile? profileImage; // Variabel untuk menyimpan gambar profil
  int _selectedTabIndex = 2; // Menyimpan index dari tab yang dipilih

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    userProfile = await apiService.getProfile();
    print(userProfile); // Tambahkan print untuk memeriksa respons API
    setState(() {
      profileImage = userProfile!['profile_picture'] != null
          ? XFile(userProfile!['profile_picture'])
          : null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        profileImage = image; // Update gambar profil di UI sebelum upload
      });

      // Upload gambar
      bool success = await apiService.updateProfilePicture(image);

      if (success) {
        // Jika upload sukses, minta profil terbaru dari server
        await _getProfile(); // Memuat ulang profil dari server untuk mendapatkan URL terbaru
        _showSnackBar('Foto profil berhasil diperbarui.');
      } else {
        _showSnackBar('Gagal memperbarui foto profil.');
      }
    }
  }

  Future<void> _logout() async {
    // Menampilkan dialog konfirmasi logout
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Kembali dengan nilai false
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Kembali dengan nilai true
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    // Jika pengguna mengonfirmasi untuk logout
    if (confirmLogout == true) {
      await apiService.logout(); // Panggil metode logout
      _showSnackBar('Anda telah logout.'); // Tampilkan pesan
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) =>
                LoginScreen()), // Ganti dengan halaman login yang sesuai
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
        automaticallyImplyLeading: false,
      ),
      body: userProfile == null
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                // Bagian foto profil
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            backgroundImage: profileImage != null
                                ? NetworkImage(
                                    '$baseUrl${userProfile!['profile_picture']}?v=${DateTime.now().millisecondsSinceEpoch}')
                                : (userProfile!['profile_picture'] != null
                                    ? NetworkImage(
                                        '$baseUrl${userProfile!['profile_picture']}?v=${DateTime.now().millisecondsSinceEpoch}')
                                    : null),
                            child: profileImage == null &&
                                    userProfile!['profile_picture'] == null
                                ? Icon(Icons.person,
                                    size: 50, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userProfile!['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userProfile!['email'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Center(
                              child: Text(
                                userProfile!['alamat'] ??
                                    'Alamat tidak tersedia',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tata letak tombol-tombol
                const SizedBox(height: 24),

                // Menampilkan tombol secara horizontal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showUbahAlamatDialog(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text('Ubah Alamat'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showUbahPasswordDialog(context),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text('Ubah Password'),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _logout,
        child: const Icon(Icons.logout), // Ikon logout
        tooltip: 'Logout',
      ),
    );
  }

  // Dialog untuk mengubah alamat
  void _showUbahAlamatDialog(BuildContext context) {
    TextEditingController alamatController =
        TextEditingController(text: userProfile!['alamat']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Alamat'),
          content: TextField(
            controller: alamatController,
            decoration: const InputDecoration(hintText: "Masukkan alamat baru"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                bool success =
                    await apiService.updateAlamat(alamatController.text);
                Navigator.of(context).pop();

                if (success) {
                  setState(() {
                    userProfile!['alamat'] = alamatController.text;
                  });
                  _showSnackBar('Alamat berhasil diperbarui.');
                } else {
                  _showSnackBar('Gagal memperbarui alamat.');
                }
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  // Dialog untuk mengubah password
  void _showUbahPasswordDialog(BuildContext context) {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController newPasswordConfirmationController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration:
                    const InputDecoration(hintText: "Password saat ini"),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(hintText: "Password baru"),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordConfirmationController,
                decoration:
                    const InputDecoration(hintText: "Konfirmasi password baru"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                bool success = await apiService.updatePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                  newPasswordConfirmationController.text,
                );
                Navigator.of(context).pop();

                if (success) {
                  _showSnackBar('Password berhasil diperbarui.');
                } else {
                  _showSnackBar('Gagal memperbarui password.');
                }
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk membangun tombol tab
  Widget _buildTabButton(String text, int index) {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    bool isActive = _selectedTabIndex == index; // Cek apakah tab ini aktif

    return GestureDetector(
      onTap: () async {
        final role = await storage.read(key: 'role');

        setState(() {
          _selectedTabIndex = index; // Ubah tab yang aktif
        });

        // Aksi ketika tab di-klik berdasarkan index
        if (index == 0) {
          if (role == 'pengajar') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InformasiPelatihanPengajarScreen()));
          } else if (role == 'user'){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InformasiPelatihanScreen()));
          }
        } else if (index == 1) {
          if (role == 'pengajar') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MonitoringScreenPengajar()));
          } else if (role == 'user'){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MonitoringScreen()));
          }
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

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
