import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditKategoriWidget extends StatefulWidget {
  final int id;
  final String namaAwal;

  const EditKategoriWidget({
    super.key,
    required this.id,
    required this.namaAwal,
  });

  @override
  State<EditKategoriWidget> createState() => _EditKategoriWidgetState();
}

class _EditKategoriWidgetState extends State<EditKategoriWidget> {
  late TextEditingController _namaC;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController(text: widget.namaAwal);
  }

  Future<void> update() async {
    setState(() => loading = true);

    await Supabase.instance.client
        .from('kategori')
        .update({'nama': _namaC.text})
        .eq('id', widget.id);

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
              'Edit Kategori',
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

            ElevatedButton(
              onPressed: loading ? null : update,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
