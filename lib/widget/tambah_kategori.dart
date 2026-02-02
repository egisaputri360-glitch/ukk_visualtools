import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahKategoriWidget extends StatefulWidget {
  const TambahKategoriWidget({super.key});

  @override
  State<TambahKategoriWidget> createState() => _TambahKategoriWidgetState();
}

class _TambahKategoriWidgetState extends State<TambahKategoriWidget> {
  final _namaC = TextEditingController();
  bool loading = false;

  Future<void> simpan() async {
    setState(() => loading = true);

    await Supabase.instance.client.from('kategori').insert({
      'nama': _namaC.text,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tambah Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _namaC,
              decoration: InputDecoration(
                hintText: 'Nama kategori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: loading ? null : simpan,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Simpan'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}