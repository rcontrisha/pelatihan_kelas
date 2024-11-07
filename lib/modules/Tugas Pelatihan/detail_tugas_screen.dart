import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pelatihan_kelas/services/api_services.dart';

class DetailTugasScreen extends StatefulWidget {
  final Map<String, dynamic> tugas;
  final int pelatihanId;

  const DetailTugasScreen(
      {Key? key, required this.tugas, required this.pelatihanId})
      : super(key: key);

  @override
  _DetailTugasScreenState createState() => _DetailTugasScreenState();
}

class _DetailTugasScreenState extends State<DetailTugasScreen> {
  String? _fileName; // Variabel untuk menyimpan nama file
  File? _selectedFile; // Variabel untuk menyimpan objek File
  bool _isFileSelected = false; // Menandakan apakah file telah dipilih
  bool _isTugasDikumpulkan = false; // Menyimpan status pengumpulan tugas
  String? _uploadedFileName; // Menyimpan nama file yang diupload
  String waktuLebihCepat = '';

  Future<Map<String, dynamic>> _cekPengumpulanTugas() async {
    ApiService apiService = ApiService();
    var response = await apiService.cekPengumpulanTugas(
        widget.tugas['id'], widget.pelatihanId);
    return response ?? {}; // Kembalikan response atau objek kosong
  }

  String formatTanggal(String? dateString) {
    if (dateString == null) return '';
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMMM y').format(date);
  }

  String waktuTersisa(String? dateString) {
    if (dateString == null) return 'Tidak ditentukan';
    DateTime batasWaktu = DateTime.parse(dateString);
    DateTime sekarang = DateTime.now();

    Duration difference = batasWaktu.difference(sekarang);

    if (difference.isNegative) {
      Duration terlambat = sekarang.difference(batasWaktu);
      if (terlambat.inDays > 0) {
        return 'Terlambat ${terlambat.inDays} hari';
      } else if (terlambat.inHours > 0) {
        return 'Terlambat ${terlambat.inHours} jam';
      } else if (terlambat.inMinutes > 0) {
        return 'Terlambat ${terlambat.inMinutes} menit';
      } else {
        return 'Baru saja terlambat';
      }
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari tersisa';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam tersisa';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit tersisa';
    } else {
      return 'Waktu hampir habis';
    }
  }

  Future<void> uploadTugas(BuildContext context) async {
    // Gunakan FilePicker untuk memilih file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      // Dapatkan file
      final filePath = result.files.single.path;
      if (filePath != null) {
        // Buat objek File
        final file = File(filePath);
        setState(() {
          _fileName = result.files.single.name; // Simpan nama file yang dipilih
          _selectedFile = file; // Simpan objek File
          _isFileSelected = true; // Menandakan file telah dipilih
        });
      }
    }
  }

  Future<void> submitUpload(BuildContext context) async {
    if (_isFileSelected && _selectedFile != null) {
      ApiService apiService = ApiService();
      var response =
          await apiService.uploadTugas(widget.tugas['id'], _selectedFile!);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tugas berhasil diupload!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengupload tugas!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Tugas'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _cekPengumpulanTugas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Tampilkan indikator loading saat menunggu
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Tangani error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Ambil data dari snapshot
            final data = snapshot.data;
            if (data != null && data['data'] != null) {
              _isTugasDikumpulkan = true; // Siswa sudah mengumpulkan tugas
              _uploadedFileName = data['data']['file_path']
                  ?.split('/')
                  ?.last; // Ambil nama file dari path

              // Menyimpan tanggal pengumpulan dan batas waktu
              DateTime waktuPengumpulan =
                  DateTime.parse(data['data']['created_at']);
              DateTime batasWaktu = DateTime.parse(widget.tugas['batas_waktu']);
              Duration selisih = batasWaktu.difference(waktuPengumpulan);

              if (selisih.isNegative) {
                // Jika tugas dikumpulkan terlambat
                Duration keterlambatan =
                    waktuPengumpulan.difference(batasWaktu);
                if (keterlambatan.inDays > 0) {
                  waktuLebihCepat =
                      'Tugas dikumpulkan terlambat ${keterlambatan.inDays} hari';
                } else if (keterlambatan.inHours > 0) {
                  waktuLebihCepat =
                      'Tugas dikumpulkan terlambat ${keterlambatan.inHours} jam';
                } else if (keterlambatan.inMinutes > 0) {
                  waktuLebihCepat =
                      'Tugas dikumpulkan terlambat ${keterlambatan.inMinutes} menit';
                } else {
                  waktuLebihCepat = 'Tugas baru saja terlambat';
                }
              } else {
                // Jika tugas dikumpulkan lebih cepat atau tepat waktu
                if (selisih.inDays > 0) {
                  waktuLebihCepat =
                      'Tugas dikumpulkan ${selisih.inDays} hari lebih cepat';
                } else if (selisih.inHours > 0) {
                  waktuLebihCepat =
                      'Tugas dikumpulkan ${selisih.inHours} jam lebih cepat';
                } else if (selisih.inMinutes > 0) {
                  waktuLebihCepat =
                      'Tugas dikumpulkan ${selisih.inMinutes} menit lebih cepat';
                } else {
                  waktuLebihCepat = 'Tugas dikumpulkan tepat waktu';
                }
              }
            } else {
              _isTugasDikumpulkan = false; // Siswa belum mengumpulkan tugas
              _uploadedFileName = null; // Reset nama file
            }

            return Column(
              children: [
                _buildTabBar(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tugas['judul'] ?? 'Judul Tugas',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.tugas['deskripsi'] ?? 'Deskripsi tidak tersedia',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tenggat: ${formatTanggal(widget.tugas['batas_waktu'])}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '(${waktuTersisa(widget.tugas['batas_waktu'])})',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red),
                      ),
                      const SizedBox(height: 32),
                      _buildUploadContainer(context),
                      SizedBox(height: 15),
                      if (_isFileSelected) // Jika file dipilih, tampilkan tombol Upload
                        Center(
                          child: ElevatedButton(
                            onPressed: () => submitUpload(context),
                            child: const Text('Upload Tugas'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildUploadContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          const Text(
            'Upload Tugas Anda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (_isTugasDikumpulkan &&
              _uploadedFileName != null) // Jika sudah mengumpulkan tugas
            Column(
              children: [
                Text(
                  'File yang diupload: $_uploadedFileName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Text(
                    'Tugas sudah dikumpulkan $waktuLebihCepat',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.green,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            )
          else if (!_isTugasDikumpulkan) // Jika belum mengumpulkan tugas
            InkWell(
              onTap: () {
                uploadTugas(context); // Memanggil fungsi upload file
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  children: [
                    if (_isFileSelected) // Jika file telah dipilih, tampilkan nama file
                      Text(
                        _fileName!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    else
                      Container(
                        width: 120,
                        height: 120,
                        child: CustomPaint(
                          painter: DashedCirclePainter(),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                const Text(
                                  'Upload',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
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

class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 5;
    double dashSpace = 5;
    double radius = (size.width / 2) - 2; // 2 is for padding from the border

    var path = Path();
    for (double i = 0; i < 360; i += dashWidth + dashSpace) {
      double radians = i * (3.1415926535897932 / 180);
      double x1 = radius + radius * cos(radians);
      double y1 = radius + radius * sin(radians);
      double x2 = radius + (radius - dashWidth) * cos(radians);
      double y2 = radius + (radius - dashWidth) * sin(radians);
      path.moveTo(x1, y1);
      path.lineTo(x2, y2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
