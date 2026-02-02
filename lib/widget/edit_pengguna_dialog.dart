import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPenggunaDialog extends StatefulWidget {
  final int? id;
  final String? nama;
  final String? role;
  final String? email;

  const EditPenggunaDialog({
    super.key,
    this.id,
    this.nama,
    this.role,
    this.email,
  });

  @override
  State<EditPenggunaDialog> createState() => _EditPenggunaDialogState();
}

class _EditPenggunaDialogState extends State<EditPenggunaDialog> {
  final supabase = Supabase.instance.client;

  late TextEditingController nama;
  late TextEditingController role;
  late TextEditingController email;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    nama = TextEditingController(text: widget.nama ?? '');
    role = TextEditingController(text: widget.role ?? '');
    email = TextEditingController(text: widget.email ?? '');
  }

  // 🔹 POPUP BERHASIL (MENYATU DI FILE INI)
  void _showBerhasil() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              SizedBox(height: 12),
              Text(
                'Berhasil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1300), () {
      Navigator.pop(context); // tutup popup
    });
  }

  Future<void> simpan() async {
  if (widget.id == null) return; // ⬅️ PENTING

  setState(() => loading = true);

  await supabase.from('users').update({
    'nama': nama.text,
    'role': role.text,
    'email': email.text,
  }).eq('id', widget.id!); // ⬅️ pakai !
    if (!mounted) return;

    _showBerhasil();

    await Future.delayed(const Duration(milliseconds: 1400));
    Navigator.pop(context, true); // tutup dialog edit + kirim result
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Pengguna',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _input(nama, 'Nama'),
            _input(role, 'Role'),
            _input(email, 'Email'),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: loading ? null : simpan,
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}