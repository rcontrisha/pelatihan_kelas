import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pelatihan_kelas/services/api_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MateriPelatihanScreen extends StatefulWidget {
  final int pelatihanId;

  const MateriPelatihanScreen({Key? key, required this.pelatihanId})
      : super(key: key);

  @override
  _MateriPelatihanScreenState createState() => _MateriPelatihanScreenState();
}

class _MateriPelatihanScreenState extends State<MateriPelatihanScreen> {
  late Future<List<dynamic>?> _materiListFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _materiListFuture = _apiService.getMaterisByPelatihanId(widget.pelatihanId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi Pelatihan'),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
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
                    final isVideo = materi['link_video'] != null;
                    final filePath = materi['file_path'];
                    final youtubeLink = materi['link_video'];

                    return _buildMateriItem(
                      materi['judul'],
                      materi['deskripsi'],
                      filePath,
                      isVideo: isVideo,
                      youtubeLink: youtubeLink,
                    );
                  },
                );
              },
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

  Widget _buildMateriItem(String title, String subTitle, String? filePath,
      {bool isVideo = false, String? youtubeLink}) {
    String fileUrl = filePath != null ? getFullFileUrl(filePath) : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jika ada link video, tampilkan video YouTube
            if (youtubeLink != null && youtubeLink.isNotEmpty)
              Container(
                height: 200,
                child: YoutubePlayerBuilder(
                  player: YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId:
                          YoutubePlayer.convertUrlToId(youtubeLink)!,
                      flags: const YoutubePlayerFlags(
                        autoPlay: false,
                        mute: false,
                        enableCaption: false,
                      ),
                    ),
                    showVideoProgressIndicator: true,
                    onReady: () {
                      // Do something when the player is ready.
                    },
                  ),
                  builder: (context, player) {
                    return Column(
                      children: [
                        player,
                        IconButton(
                          icon: const Icon(Icons.fullscreen),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FullScreenYoutubePlayer(
                                  youtubeLink: youtubeLink,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              )
            // Jika tidak ada video, tampilkan ikon dokumen atau thumbnail file materi
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors
                    .grey[200], // Background abu-abu jika tidak ada thumbnail
                child: filePath != null
                    ? Image.network(
                        fileUrl, // Thumbnail dari file materi
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.insert_drive_file,
                              size: 50, color: Colors.grey);
                        },
                      )
                    : const Icon(
                        Icons.insert_drive_file,
                        size: 50,
                        color: Colors.grey,
                      ),
              ),

            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              subTitle,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 8),
            if (filePath != null)
              ElevatedButton.icon(
                onPressed: () => _downloadFile(fileUrl, '$title.pdf'),
                icon: const Icon(Icons.download),
                label: const Text('Download File Materi'),
              )
            else
              const Text(
                'Tidak ada file yang tersedia untuk diunduh.',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      if (await _requestPermission(Permission.storage)) {
        Directory? downloadDir = Directory('/storage/emulated/0/Download');

        if (downloadDir.existsSync()) {
          String downloadPath = '${downloadDir.path}/$fileName';

          Dio dio = Dio();
          await dio.download(url, downloadPath);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File downloaded to: $downloadPath')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download directory does not exist')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  String getFullFileUrl(String filePath) {
    const String baseUrl = "http://192.168.114.163:8000";
    return "$baseUrl/storage/$filePath";
  }
}

class FullScreenYoutubePlayer extends StatelessWidget {
  final String youtubeLink;

  const FullScreenYoutubePlayer({Key? key, required this.youtubeLink})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fullscreen Video'),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: YoutubePlayerController(
            initialVideoId: YoutubePlayer.convertUrlToId(youtubeLink)!,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              enableCaption: false,
            ),
          ),
          showVideoProgressIndicator: true,
          onReady: () {
            // Do something when the player is ready.
          },
        ),
      ),
    );
  }
}
