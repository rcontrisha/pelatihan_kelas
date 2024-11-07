import 'package:flutter/material.dart';
import 'package:pelatihan_kelas/services/api_services.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

// Halaman untuk daftar tugas
class DaftarTugasScreen extends StatefulWidget {
  final int pelatihanId;

  const DaftarTugasScreen({Key? key, required this.pelatihanId})
      : super(key: key);

  @override
  _DaftarTugasScreenState createState() => _DaftarTugasScreenState();
}

class _DaftarTugasScreenState extends State<DaftarTugasScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _tugasList = [];

  @override
  void initState() {
    super.initState();
    _getTugasList();
  }

  Future<void> _getTugasList() async {
    final tugasList =
        await _apiService.getTugasByPelatihanId(widget.pelatihanId);
    if (tugasList != null) {
      setState(() {
        _tugasList = tugasList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
      ),
      body: _tugasList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tugasList.length,
              itemBuilder: (context, index) {
                final tugas = _tugasList[index];
                return _buildTugasItem(
                  tugas['id'], // Tambahkan ID tugas
                  tugas['judul'],
                  tugas['deskripsi'],
                  tugas['batas_waktu'],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BuatTugasScreen(pelatihanId: widget.pelatihanId),
            ),
          ).then((_) =>
              _getTugasList()); // Refresh daftar tugas setelah tugas baru dibuat
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Tugas Baru',
      ),
    );
  }

  // Modifikasi untuk navigasi ke halaman pengumpulan tugas saat diklik
  Widget _buildTugasItem(
      int tugasId, String title, String description, String deadline) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PengumpulanTugasScreen(
                tugasId: tugasId), // Navigasi ke PengumpulanTugasScreen
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 8),
              Text(
                  'Deadline: ${DateFormat('dd MMM yyyy').format(DateTime.parse(deadline))}'),
            ],
          ),
        ),
      ),
    );
  }
}

// Halaman untuk mengumpulkan tugas
class PengumpulanTugasScreen extends StatefulWidget {
  final int tugasId;

  const PengumpulanTugasScreen({Key? key, required this.tugasId})
      : super(key: key);

  @override
  _PengumpulanTugasScreenState createState() => _PengumpulanTugasScreenState();
}

class _PengumpulanTugasScreenState extends State<PengumpulanTugasScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _pengumpulanList = [];

  @override
  void initState() {
    super.initState();
    _getPengumpulanTugas();
  }

  Future<void> _getPengumpulanTugas() async {
    final pengumpulanList =
        await _apiService.getPengumpulanTugas(widget.tugasId);
    if (pengumpulanList != null) {
      setState(() {
        _pengumpulanList = pengumpulanList;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data pengumpulan tugas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumpulan Tugas'),
      ),
      body: _pengumpulanList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pengumpulanList.length,
              itemBuilder: (context, index) {
                final pengumpulan = _pengumpulanList[index];
                return _buildPengumpulanItem(pengumpulan);
              },
            ),
    );
  }

  Widget _buildPengumpulanItem(Map<String, dynamic> pengumpulan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  'http://192.168.1.11:8000/storage/${pengumpulan['profile']}'), // Gambar profil siswa
              radius: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pengumpulan['nama'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pengumpulan['email'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tugas: ${pengumpulan['original_name']}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanggal Pengumpulan: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(pengumpulan['tanggal_pengumpulan']))}',
                    style: const TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _downloadTugas(pengumpulan['download_link']);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Tugas'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadTugas(String downloadLink) {
    // Implementasikan logika download sesuai dengan platform (mobile atau web).
    // Contoh penggunaan url_launcher untuk mendownload file di mobile/web:
    // launch('http://192.168.1.11:8000/$downloadLink');
  }
}

class BuatTugasScreen extends StatefulWidget {
  final int pelatihanId;

  const BuatTugasScreen({Key? key, required this.pelatihanId})
      : super(key: key);

  @override
  _BuatTugasScreenState createState() => _BuatTugasScreenState();
}

class _BuatTugasScreenState extends State<BuatTugasScreen> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  DateTime? _selectedDeadline; // Menyimpan tanggal deadline yang dipilih
  final ApiService _apiService = ApiService();

  Future<void> _submitTugas() async {
    String judul = _judulController.text;
    String deskripsi = _deskripsiController.text;

    if (judul.isEmpty || deskripsi.isEmpty || _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi semua bidang!')),
      );
      return;
    }

    var response = await _apiService.createTugas(
      judul,
      deskripsi,
      widget.pelatihanId,
      _selectedDeadline!
          .toIso8601String(), // Mengirim deadline sebagai string ISO 8601
    );

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil dibuat!')),
      );
      Navigator.pop(
          context); // Kembali ke halaman sebelumnya setelah tugas diunggah
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat tugas!')),
      );
    }
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tugas Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _judulController,
              decoration: const InputDecoration(
                labelText: 'Judul Tugas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Tugas',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _selectedDeadline == null
                    ? 'Pilih Tanggal Deadline'
                    : 'Deadline: ${DateFormat('dd MMM yyyy').format(_selectedDeadline!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDeadline(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitTugas,
              child: const Text('Buat Tugas'),
            ),
          ],
        ),
      ),
    );
  }
}
