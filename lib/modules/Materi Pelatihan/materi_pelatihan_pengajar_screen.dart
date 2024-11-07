import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pelatihan_kelas/services/api_services.dart';

class MateriPelatihanPengajarScreen extends StatefulWidget {
  final int pelatihanId;

  const MateriPelatihanPengajarScreen({Key? key, required this.pelatihanId})
      : super(key: key);

  @override
  _MateriPelatihanPengajarScreenState createState() =>
      _MateriPelatihanPengajarScreenState();
}

class _MateriPelatihanPengajarScreenState
    extends State<MateriPelatihanPengajarScreen> {
  late Future<List<dynamic>?> _materiListFuture;
  final ApiService _apiService = ApiService();
  String _judul = '';
  String _deskripsi = '';
  String _linkVideo = '';
  String? _selectedFilePath;

  @override
  void initState() {
    super.initState();
    _materiListFuture = _apiService.getMaterisByPelatihanId(widget.pelatihanId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi Pelatihan Pengajar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMateriDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: _materiListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading materials'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No materials found'));
          }

          final materiList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materiList.length,
            itemBuilder: (context, index) {
              final materi = materiList[index];
              return _buildMateriItem(materi);
            },
          );
        },
      ),
    );
  }

  Widget _buildMateriItem(dynamic materi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              materi['judul'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(materi['deskripsi']),
            Text(materi['link_video'] ?? 'No video link provided'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showEditMateriDialog(materi),
              child: const Text('Edit Materi'),
            ),
            ElevatedButton(
              onPressed: () => _uploadFile(materi['id']),
              child: const Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMateriDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Materi'),
          content: SingleChildScrollView(
            // Memungkinkan scroll jika konten panjang
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Judul'),
                  onChanged: (value) => _judul = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  onChanged: (value) => _deskripsi = value,
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Link Video (Opsional)'),
                  onChanged: (value) => _linkVideo = value,
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                    if (result != null) {
                      setState(() {
                        _selectedFilePath = result.files.single.path;
                      });
                    }
                  },
                  child: const Text('Pilih File (Opsional)'),
                ),
                if (_selectedFilePath != null)
                  Text('Selected File: $_selectedFilePath'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _uploadMateri();
              },
              child: const Text('Upload'),
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

  void _showEditMateriDialog(dynamic materi) {
    // Set initial values dari materi yang ingin diedit
    _judul = materi['judul'];
    _deskripsi = materi['deskripsi'];
    _linkVideo = materi['link_video'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Materi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Judul'),
                  onChanged: (value) => _judul = value,
                  controller: TextEditingController(text: _judul),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  onChanged: (value) => _deskripsi = value,
                  controller: TextEditingController(text: _deskripsi),
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Link Video (Opsional)'),
                  onChanged: (value) => _linkVideo = value,
                  controller: TextEditingController(text: _linkVideo),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateMateri(
                    materi['id']); // Panggil fungsi untuk update materi
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

  Future<void> _updateMateri(int materiId) async {
    if (_judul.isNotEmpty) {
      // hanya periksa judul yang dibutuhkan
      try {
        var response = await _apiService.updateMateriInfo(
          materiId,
          _judul,
          _deskripsi,
          _linkVideo, // Kirim link video jika ada
        );

        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Materi berhasil diperbarui')));
          setState(() {
            _materiListFuture =
                _apiService.getMaterisByPelatihanId(widget.pelatihanId);
            _judul = '';
            _deskripsi = '';
            _linkVideo = ''; // Reset link video
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal memperbarui materi')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update material: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi semua field')));
    }
  }

  Future<void> _uploadMateri() async {
    if (_judul.isNotEmpty && _deskripsi.isNotEmpty) {
      try {
        var response = await _apiService.createMateri(
          widget.pelatihanId,
          _judul,
          _deskripsi,
          _linkVideo, // Kirim link video jika ada
          filePath: _selectedFilePath, // Kirim file path untuk diupload
        );

        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Materi berhasil diunggah')));
          setState(() {
            _materiListFuture =
                _apiService.getMaterisByPelatihanId(widget.pelatihanId);
            _selectedFilePath = null; // Reset file path
            _judul = '';
            _deskripsi = '';
            _linkVideo = ''; // Reset link video
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal mengunggah materi')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload material: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi semua field')));
    }
  }

  Future<void> _uploadFile(int materiId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      _selectedFilePath = result.files.single.path;

      if (_selectedFilePath != null) {
        try {
          var response =
              await _apiService.uploadMateriFile(materiId, _selectedFilePath!);
          if (response != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File berhasil diunggah')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gagal mengunggah file')));
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload file: $e')));
        }
      }
    }
  }
}
