import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart'; // Import path package
import 'package:image_picker/image_picker.dart';

class ApiService {
  final String baseUrl =
      'http://172.16.7.93:8000/api'; // Ganti dengan URL API Anda
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Registrasi pengguna
  Future<Map<String, dynamic>?> register(
      String name, String email, String password, String role) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password, // Konfirmasi password
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      // Handle error response
      return null;
    }
  }

  // Login pengguna
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      await storage.write(key: 'token', value: body['access_token']);
      await storage.write(key: 'role', value: body['role']);
      return body;
    } else {
      // Handle error response
      return null;
    }
  }

  // Logout pengguna
  Future<void> logout() async {
    final token = await storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/logout');
    await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    await storage.delete(key: 'token');
  }

  // Mendapatkan daftar pelatihan
  Future<List<dynamic>?> getPelatihans() async {
    final token = await storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/pelatihans');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      debugPrint(response.body);
      return jsonDecode(response.body);
    } else {
      // Handle error response
      return null;
    }
  }

  // Fungsi untuk mengambil data detail pelatihan berdasarkan ID
  Future<Map<String, dynamic>?> getPelatihanDetail(int pelatihanId) async {
    final token = await storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/pelatihans/$pelatihanId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Menambahkan pelatihan baru
  Future<Map<String, dynamic>?> createPelatihan(
      String nama, String deskripsi) async {
    final token = await storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/pelatihans');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama': nama,
        'deskripsi': deskripsi,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      // Handle error response
      return null;
    }
  }

  // Mendapatkan daftar pelatihan yang diikuti oleh pengguna
  Future<List<dynamic>?> getUserTrainings() async {
    final token = await storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/user-training');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle error response
      return null;
    }
  }

  // Menambahkan pelatihan yang diikuti oleh pengguna
  Future<Map<String, dynamic>?> joinPelatihan(int pelatihanId, String fullName,
      String nik, String address, String phoneNumber) async {
    final token = await storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/user-training');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'pelatihan_id': pelatihanId,
        'full_name': fullName,
        'nik': nik,
        'address': address,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      // Handle error response
      return null;
    }
  }

  // Menambahkan materi baru
  Future<Map<String, dynamic>?> createMateri(
      int pelatihanId, String judul, String deskripsi, String linkVideo,
      {String? filePath}) async {
    final token = await storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/materis');
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Tambahkan field
    request.fields['pelatihan_id'] = pelatihanId.toString();
    request.fields['judul'] = judul;
    request.fields['deskripsi'] = deskripsi;
    request.fields['link_video'] = linkVideo;

    // Tambahkan file jika ada
    if (filePath != null) {
      request.files
          .add(await http.MultipartFile.fromPath('file_path', filePath));
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } else {
      // Handle error response
      return null;
    }
  }

  // Mendapatkan daftar materi berdasarkan ID pelatihan
  Future<List<dynamic>?> getMaterisByPelatihanId(int pelatihanId) async {
    final token = await storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/materis/$pelatihanId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle error response
      return null;
    }
  }

  // Mendapatkan daftar tugas berdasarkan ID pelatihan
  Future<List<dynamic>?> getTugasByPelatihanId(int pelatihanId) async {
    final token = await storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/tugas/$pelatihanId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle error response
      return null;
    }
  }

  // Fungsi untuk mengupload tugas (pengumpulan tugas)
  Future<Map<String, dynamic>?> uploadTugas(int tugasId, File file) async {
    final token =
        await storage.read(key: 'token'); // Ambil token dari penyimpanan aman
    final url =
        Uri.parse('$baseUrl/pengumpulan-tugas'); // Endpoint untuk upload tugas

    // Membuat request multipart
    var request = http.MultipartRequest('POST', url);

    // Menambahkan header Authorization dengan Bearer Token
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';

    // Menambahkan field tugas_id
    request.fields['tugas_id'] = tugasId.toString();

    // Menambahkan file ke dalam request
    var stream = http.ByteStream(file.openRead());
    var length = await file.length();
    var multipartFile = http.MultipartFile('file_path', stream, length,
        filename: basename(file.path));

    request.files.add(multipartFile);

    // Mengirim request dan mendapatkan response
    var response = await request.send();

    if (response.statusCode == 201) {
      // Jika berhasil diupload
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } else {
      // Jika gagal
      return null;
    }
  }

  Future<dynamic> cekPengumpulanTugas(int tugasId, int pelatihanId) async {
    final url = Uri.parse(
        '$baseUrl/pengumpulan-tugas/cek?tugas_id=$tugasId&pelatihan_id=$pelatihanId'); // Endpoint untuk pengecekan pengumpulan
    final token =
        await storage.read(key: 'token'); // Ambil token dari penyimpanan aman

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Jika Anda menggunakan autentikasi, tambahkan token di sini
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        return jsonDecode(response.body); // Kembalikan data jika berhasil
      } else {
        print("Pengecekan Gagal. Status Code: ${response.statusCode}");
        return null; // Kembalikan null jika gagal
      }
    } catch (e) {
      print('Error: $e');
      return null; // Kembalikan null jika terjadi error
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final token =
        await storage.read(key: 'token'); // Ambil token dari penyimpanan aman

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      return null;
    }
  }

  Future<bool> updateAlamat(String alamat) async {
    final token =
        await storage.read(key: 'token'); // Ambil token dari penyimpanan aman

    final response = await http.post(
      Uri.parse('$baseUrl/profile/update-alamat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'alamat': alamat,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updatePassword(String currentPassword, String newPassword,
      String newPasswordConfirmation) async {
    final token =
        await storage.read(key: 'token'); // Ambil token dari penyimpanan aman

    final response = await http.post(
      Uri.parse('$baseUrl/profile/update-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateProfilePicture(XFile image) async {
    final token =
        await storage.read(key: 'token'); // Ambil token dari penyimpanan aman

    // Membuat request multipart untuk upload gambar
    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/profile/update-profile-picture'));
    request.headers['Authorization'] = 'Bearer $token';

    // Menambahkan file gambar ke dalam request
    request.files
        .add(await http.MultipartFile.fromPath('profile_picture', image.path));

    // Mengirimkan request dan menunggu respons
    var response = await request.send();

    // Memeriksa status respons
    if (response.statusCode == 200) {
      return true; // Berhasil
    } else {
      return false; // Gagal
    }
  }

  // Fungsi untuk mengambil data pelatihan berdasarkan instruktur
  Future<List<dynamic>?> getPelatihanByInstruktur() async {
    try {
      final token =
          await storage.read(key: 'token'); // Mengambil token dari storage

      if (token == null) {
        throw Exception("Token tidak tersedia.");
      }

      // Endpoint untuk mengambil pelatihan instruktur
      final url = Uri.parse('$baseUrl/pelatihan/instruktur');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Kirim token sebagai header Authorization
        },
      );

      if (response.statusCode == 200) {
        // Jika berhasil, decode data JSON
        final data = jsonDecode(response.body);
        return data['data']; // Mengambil data pelatihan
      } else if (response.statusCode == 403) {
        // Jika user bukan pengajar atau tidak diizinkan
        throw Exception("Akses ditolak: Anda bukan pengajar.");
      } else {
        // Jika terjadi error lain
        throw Exception(
            "Gagal mengambil data pelatihan: ${response.statusCode}");
      }
    } catch (e) {
      // Menangkap error dan menampilkan pesan
      print("Error: $e");
      return null;
    }
  }

  // Method untuk mengambil peserta pelatihan berdasarkan pelatihan_id
  Future<List<dynamic>?> getUsersByPelatihanId(int pelatihanId) async {
    try {
      final token =
          await storage.read(key: 'token'); // Mengambil token dari storage

      if (token == null) {
        throw Exception("Token tidak tersedia.");
      }

      // Endpoint untuk mengambil pelatihan instruktur
      final url = Uri.parse('$baseUrl/pelatihan/$pelatihanId/users');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Kirim token sebagai header Authorization
        },
      );

      if (response.statusCode == 200) {
        // Decode response body menjadi List
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        // Jika response gagal, throw exception
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Helper method to get token
  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }
}
