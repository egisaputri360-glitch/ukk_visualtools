import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahPenggunaDialog extends StatefulWidget {
  const TambahPenggunaDialog({super.key});

  @override
  State<TambahPenggunaDialog> createState() => _TambahPenggunaDialogState();
}

class _TambahPenggunaDialogState extends State<TambahPenggunaDialog> {
  final supabase = Supabase.instance.client;

  final namaController = TextEditingController();
  final roleController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final kelasController = TextEditingController();     // ⬅️ BARU
  final jurusanController = TextEditingController();   // ⬅️ BARU

  bool loading = false;

  Future<void> simpan() async {
    if (namaController.text.isEmpty ||
        roleController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        kelasController.text.isEmpty ||
        jurusanController.text.isEmpty) {
      return;
    }

    setState(() => loading = true);

    await supabase.from('users').insert({
      'nama': namaController.text,
      'role': roleController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'kelas': kelasController.text,       // ⬅️ BARU
      'jurusan': jurusanController.text,   // ⬅️ BARU
    });

    setState(() => loading = false);

    if (context.mounted) {
      Navigator.pop(context, true); // ⬅️ balik ke UserPage
    }
  }

  Widget input(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tambah Pengguna',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              input('Nama :', namaController),
              const SizedBox(height: 12),

              input('Role :', roleController),
              const SizedBox(height: 12),

              input('Email :', emailController),
              const SizedBox(height: 12),

              input('Kata sandi :', passwordController, obscure: true),
              const SizedBox(height: 12),

              input('Kelas :', kelasController),        // ⬅️ BARU
              const SizedBox(height: 12),

              input('Jurusan :', jurusanController),    // ⬅️ BARU
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: loading ? null : simpan,
                    child: loading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}