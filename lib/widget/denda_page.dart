import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DendaPage extends StatefulWidget {
  final int idPengembalian;
  final bool terlambat;
  final bool rusak;
  final int hariTerlambat;

  const DendaPage({
    super.key,
    required this.idPengembalian,
    required this.terlambat,
    required this.rusak,
    required this.hariTerlambat, required String jenisDenda, required int totalDenda,
  });

  @override
  State<DendaPage> createState() => _DendaPageState();
}

class _DendaPageState extends State<DendaPage> {
  final supabase = Supabase.instance.client;
  int totalDenda = 0;
  String jenisDenda = '';

  @override
  void initState() {
    super.initState();
    hitungDenda();
  }

  void hitungDenda() {
    int denda = 0;
    List<String> jenis = [];

    if (widget.terlambat) {
      denda += widget.hariTerlambat * 5000;
      jenis.add('Terlambat');
    }

    if (widget.rusak) {
      denda += 20000;
      jenis.add('Rusak');
    }

    totalDenda = denda;
    jenisDenda = jenis.join(' & ');
  }

  Future<void> simpanDenda() async {
    await supabase.from('denda').insert({
      'id_pengembalian': widget.idPengembalian,
      'jenis_denda': jenisDenda,
      'total_denda': totalDenda,
      'status_bayar': 'belum',
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Denda')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jenis Denda: $jenisDenda'),
            const SizedBox(height: 10),
            Text(
              'Total: Rp $totalDenda',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: simpanDenda,
              child: const Text('Simpan Denda'),
            )
          ],
        ),
      ),
    );
  }
}