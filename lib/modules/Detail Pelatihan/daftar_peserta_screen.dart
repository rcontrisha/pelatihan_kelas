import 'package:flutter/material.dart';
import 'package:pelatihan_kelas/services/api_services.dart';

class PesertaPelatihanScreen extends StatefulWidget {
  final int pelatihanId;

  const PesertaPelatihanScreen({Key? key, required this.pelatihanId})
      : super(key: key);

  @override
  _PesertaPelatihanScreenState createState() => _PesertaPelatihanScreenState();
}

class _PesertaPelatihanScreenState extends State<PesertaPelatihanScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>?> _pesertaPelatihan;
  String baseUrl =
      'http://192.168.114.163:8000/storage/'; // Ganti dengan URL server Anda

  @override
  void initState() {
    super.initState();
    // Panggil API untuk mendapatkan daftar peserta berdasarkan pelatihanId
    _pesertaPelatihan = apiService.getUsersByPelatihanId(widget.pelatihanId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Peserta Pelatihan'),
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: _pesertaPelatihan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Tidak ada peserta yang terdaftar.'));
          } else {
            final pesertaList = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: pesertaList.length,
                itemBuilder: (context, index) {
                  final peserta = pesertaList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: peserta['user']['profile_picture'] !=
                              null
                          ? NetworkImage(
                              '$baseUrl${peserta['user']['profile_picture']}')
                          : null, // URL foto profil peserta
                      child: peserta['user']['profile_picture'] == null
                          ? const Icon(Icons
                              .person) // Icon default jika foto tidak tersedia
                          : null,
                    ),
                    title: Text(peserta['full_name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NIK: ${peserta['nik']}'),
                        Text('Alamat: ${peserta['address']}'),
                        Text('No. Telp: ${peserta['phone_number']}'),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
