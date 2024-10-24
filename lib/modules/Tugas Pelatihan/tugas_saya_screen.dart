import 'package:flutter/material.dart';
import 'package:pelatihan_kelas/modules/Tugas Pelatihan/detail_tugas_screen.dart';
import 'package:pelatihan_kelas/services/api_services.dart';

class TugasSayaScreen extends StatefulWidget {
  final int pelatihanId;

  const TugasSayaScreen({Key? key, required this.pelatihanId})
      : super(key: key);

  @override
  _TugasSayaScreenState createState() => _TugasSayaScreenState();
}

class _TugasSayaScreenState extends State<TugasSayaScreen> {
  late Future<List<dynamic>?> _tugasListFuture;
  final ApiService _apiService = ApiService();
  List<dynamic> _tugasList = [];
  int _selectedTabIndex = 1; // Menyimpan index dari tab yang dipilih

  @override
  void initState() {
    super.initState();
    _tugasListFuture = _apiService.getTugasByPelatihanId(widget.pelatihanId);
    _getTugasAndCheckSubmission();
  }

  Future<void> _getTugasAndCheckSubmission() async {
    final tugasList =
        await _apiService.getTugasByPelatihanId(widget.pelatihanId);
    if (tugasList != null) {
      // Panggil pengecekan pengumpulan tugas untuk setiap tugas
      for (var tugas in tugasList) {
        var response = await _apiService.cekPengumpulanTugas(
            tugas['id'], widget.pelatihanId);
        tugas['isDikumpulkan'] = response != null &&
            response['data'] != null; // Tandai jika sudah dikumpulkan
      }
      setState(() {
        _tugasList =
            tugasList; // Simpan tugas yang sudah diperiksa ke dalam state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Saya'),
      ),
      body: _tugasList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tugasList.length,
                    itemBuilder: (context, index) {
                      final tugas = _tugasList[index];
                      return _buildTugasItem(tugas['judul'], tugas);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTugasItem(String title, Map<String, dynamic> tugas) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTugasScreen(
              tugas: tugas,
              pelatihanId: widget.pelatihanId,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Tampilkan ikon centang jika tugas sudah dikumpulkan
              if (tugas['isDikumpulkan'] == true)
                const Icon(Icons.check, color: Colors.green)
              else
                const Icon(Icons.arrow_forward),
            ],
          ),
        ),
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
}
