import 'package:flutter/material.dart';

import 'widgets/kelas_saya_list.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring'),
      ),
      body: const KelasSayaList(),
    );
  }
}