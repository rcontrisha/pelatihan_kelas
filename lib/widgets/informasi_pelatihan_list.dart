import 'package:flutter/material.dart';

import '../detail_pelatihan_screen.dart';

class InformasiPelatihanList extends StatelessWidget {
  const InformasiPelatihanList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildPelatihanItem(context);
      },
    );
  }

  Widget _buildPelatihanItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetailPelatihanScreen()),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Center(child: Text('Foto Pelatihan')),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Nama Pelatihan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('Deskripsi Pelatihan'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}