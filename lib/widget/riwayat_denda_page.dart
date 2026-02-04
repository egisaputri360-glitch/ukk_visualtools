import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const primaryGreen = Color(0xFFB2CF99);
const bgSoft = Color(0xFFF6FAF4);

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> dendaList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDenda();
  }

  // ================= FETCH =================
  Future<void> fetchDenda() async {
    setState(() => isLoading = true);
    try {
      final res = await supabase
          .from('denda')
          .select()
          .order('id_denda', ascending: false);

      dendaList = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      _showSnackbar('Gagal memuat data: $e', Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= TAMBAH / EDIT =================
  void openForm({Map<String, dynamic>? data}) {
    final jenisC = TextEditingController(text: data?['jenis_denda'] ?? '');
    final totalC =
        TextEditingController(text: data?['total_denda']?.toString() ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(data == null ? 'Tambah Denda' : 'Edit Denda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jenisC,
              decoration: const InputDecoration(labelText: 'Jenis Denda'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: totalC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total Denda'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            onPressed: () async {
              if (jenisC.text.trim().isEmpty ||
                  totalC.text.trim().isEmpty) {
                _showSnackbar('Semua field wajib diisi', Colors.red);
                return;
              }

              final payload = {
                'jenis_denda': jenisC.text.trim(),
                'total_denda': int.parse(totalC.text),
                'id_pengembalian': 1, // WAJIB sesuai DB kamu
              };

              try {
                if (data == null) {
                  // TAMBAH
                  await supabase
                      .from('denda')
                      .insert(payload)
                      .select(); // ⬅️ FIX PENTING
                } else {
                  // EDIT
                  await supabase
                      .from('denda')
                      .update(payload)
                      .eq('id_denda', data['id_denda'])
                      .select(); // ⬅️ FIX PENTING
                }

                if (!mounted) return;
                Navigator.pop(ctx); // ⬅️ popup pasti nutup
                await fetchDenda();
                _showSnackbar('Data berhasil disimpan', primaryGreen);
              } catch (e) {
                _showSnackbar('Gagal menyimpan: $e', Colors.red);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ================= DELETE =================
  Future<void> deleteDenda(Map<String, dynamic> item) async {
    try {
      await supabase
          .from('denda')
          .delete()
          .eq('id_denda', item['id_denda'])
          .select(); // ⬅️ konsisten

      await fetchDenda();
      _showSnackbar('Data berhasil dihapus', primaryGreen);
    } catch (e) {
      _showSnackbar('Gagal menghapus: $e', Colors.red);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text(
          'Denda',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => openForm(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dendaList.isEmpty
              ? const Center(child: Text('Belum ada data denda'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dendaList.length,
                  itemBuilder: (context, index) {
                    final item = dendaList[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(item['jenis_denda']),
                        subtitle: Text('Rp ${item['total_denda']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blue),
                              onPressed: () => openForm(data: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () => deleteDenda(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // ================= SNACKBAR =================
  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }
}