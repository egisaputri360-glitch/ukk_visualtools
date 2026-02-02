import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _namaController = TextEditingController();

  /// ================= GET DATA =================
  Future<List<dynamic>> fetchKategori() async {
    final data = await supabase
        .from('kategori')
        .select()
        .order('id', ascending: false);

    return data;
  }

  /// ================= TAMBAH =================
  Future<void> tambahKategori() async {
    if (_namaController.text.trim().isEmpty) return;

    await supabase.from('kategori').insert({
      'nama': _namaController.text.trim(),
    });

    _namaController.clear();
    Navigator.pop(context);
    setState(() {});
    _popupBerhasil('Kategori berhasil ditambahkan');
  }

  /// ================= EDIT =================
  Future<void> editKategori(int id) async {
    if (_namaController.text.trim().isEmpty) return;

    await supabase
        .from('kategori')
        .update({'nama': _namaController.text.trim()})
        .eq('id', id);

    _namaController.clear();
    Navigator.pop(context);
    setState(() {});
    _popupBerhasil('Kategori berhasil diubah');
  }

  /// ================= HAPUS =================
  Future<void> hapusKategori(int id) async {
    await supabase.from('kategori').delete().eq('id', id);
    Navigator.pop(context);
    setState(() {});
    _popupBerhasil('Kategori berhasil dihapus');
  }

  /// ================= POPUP =================
  void _popupBerhasil(String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        Timer(const Duration(seconds: 1), () => Navigator.pop(context));
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 40),
                const SizedBox(height: 10),
                Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ================= FORM DIALOG =================
  void _formDialog({
    required String title,
    required VoidCallback onSave,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  hintText: 'nama :',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () {
                      _namaController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: onSave,
                    child: const Text('Simpan'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFB8D8A0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Kategori",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _namaController.clear();
                      _formDialog(
                        title: 'Tambah Kategori',
                        onSave: tambahKategori,
                      );
                    },
                  )
                ],
              ),
            ),

            /// LIST
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchKategori(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;

                  if (data.isEmpty) {
                    return const Center(child: Text('Data kosong'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];

                      final int id = item['id'];
                      final String nama =
                          item['nama']?.toString() ?? '-';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                nama,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () {
                                _namaController.text = nama;
                                _formDialog(
                                  title: 'Edit Kategori',
                                  onSave: () => editKategori(id),
                                );
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete_outline),
                              onPressed: () => hapusKategori(id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}