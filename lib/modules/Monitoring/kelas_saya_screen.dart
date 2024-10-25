import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pelatihan_kelas/modules/Tugas%20Pelatihan/tugas_pengajar_screen.dart';
import 'package:pelatihan_kelas/modules/Tugas%20Pelatihan/tugas_saya_screen.dart';
import '../Materi Pelatihan/materi_pelatihan_screen.dart';
import '../Materi Pelatihan/materi_pelatihan_pengajar_screen.dart'; // Import halaman materi untuk pengajar
// import '../Tugas Pelatihan/tugas_pengajar_screen.dart'; // Import halaman tugas untuk pengajar

class KelasSayaScreen extends StatefulWidget {
  final int pelatihanId; // Menyimpan ID pelatihan yang dipilih
  const KelasSayaScreen({Key? key, required this.pelatihanId})
      : super(key: key);

  @override
  State<KelasSayaScreen> createState() => _KelasSayaScreenState();
}

class _KelasSayaScreenState extends State<KelasSayaScreen> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? userRole; // Menyimpan role pengguna

  @override
  void initState() {
    super.initState();
    _getUserRole(); // Mengambil role pengguna saat inisialisasi
  }

  // Fungsi untuk mengambil role pengguna dari secure storage
  Future<void> _getUserRole() async {
    userRole = await storage.read(
        key: 'role'); // Ganti 'role' dengan kunci yang sesuai
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring'),
      ),
      body: Column(
        children: [

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildKelasItem(context, 'Materi Pelatihan'),
                _buildKelasItem(context, 'Tugas'),
              ],
            ),
          ),
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

  Widget _buildKelasItem(BuildContext context, String title) {
    IconData iconData;

    // Menentukan icon berdasarkan judul (Materi atau Tugas)
    if (title == 'Materi Pelatihan') {
      iconData = Icons.menu_book; // Ikon buku untuk Materi
    } else if (title == 'Tugas') {
      iconData = Icons.assignment; // Ikon tugas untuk Tugas
    } else {
      iconData = Icons.info; // Default icon jika dibutuhkan
    }

    return GestureDetector(
      onTap: () {
        if (title == 'Materi Pelatihan') {
          // Jika role pengguna adalah pengajar, navigasi ke halaman materi pengajar
          if (userRole == 'pengajar') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MateriPelatihanPengajarScreen(
                        pelatihanId: widget.pelatihanId,
                      )),
            );
          } else {
            // Jika role pengguna adalah peserta
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MateriPelatihanScreen(
                        pelatihanId: widget.pelatihanId,
                      )),
            );
          }
        } else if (title == 'Tugas') {
          // Jika role pengguna adalah pengajar, navigasi ke halaman tugas pengajar
          if (userRole == 'pengajar') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DaftarTugasScreen(
                        pelatihanId: widget.pelatihanId,
                      )),
            );
          } else {
            // Jika role pengguna adalah peserta
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TugasSayaScreen(
                        pelatihanId: widget.pelatihanId,
                      )),
            );
          }
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
                child: Center(
                  // Menggunakan ikon sebagai placeholder banner
                  child: Icon(
                    iconData,
                    size: 60, // Ukuran icon
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
