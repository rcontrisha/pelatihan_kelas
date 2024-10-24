import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pelatihan_kelas/modules/Detail%20Pelatihan/detail_pelatihan_screen.dart';
import 'package:pelatihan_kelas/services/api_services.dart';

class PendaftaranScreen extends StatefulWidget {
  final int pelatihanId; // Menyimpan ID pelatihan yang dipilih

  const PendaftaranScreen({Key? key, required this.pelatihanId})
      : super(key: key);

  @override
  _PendaftaranScreenState createState() => _PendaftaranScreenState();
}

class _PendaftaranScreenState extends State<PendaftaranScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _nomorHandphoneController =
      TextEditingController();

  final ApiService _userTrainingService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: const Center(
                  child: Text(
                    'Logo Perusahaan',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'LKP MULTI KARYA',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              const Text(
                'Pendaftaran',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildTextField('Nama Lengkap', _namaController),
              _buildTextField('Alamat', _alamatController),
              _buildTextField('NIK', _nikController),
              _buildTextField('Nomor Handphone', _nomorHandphoneController),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _handleRegistration(),
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    String nama = _namaController.text.trim();
    String alamat = _alamatController.text.trim();
    String nik = _nikController.text.trim();
    String nomorHandphone = _nomorHandphoneController.text.trim();

    if (nama.isEmpty ||
        alamat.isEmpty ||
        nik.isEmpty ||
        nomorHandphone.isEmpty) {
      _showMessage('Semua field harus diisi!');
      return;
    }

    Map<String, dynamic>? result = await _userTrainingService.joinPelatihan(
      widget.pelatihanId,
      nama,
      nik,
      alamat,
      nomorHandphone,
    );

    if (result != null) {
      _showMessage('Pendaftaran berhasil!');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DetailPelatihanScreen(pelatihanId: widget.pelatihanId)),
      );
    } else {
      _showMessage('Pendaftaran gagal. Silakan coba lagi.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
