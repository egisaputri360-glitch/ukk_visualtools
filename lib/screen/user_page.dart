import 'package:flutter/material.dart';
import 'package:krpl/widget/edit_pengguna_dialog.dart';
import 'package:krpl/widget/tambah_pengguna.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ================= FETCH =================
  Future<void> fetchUsers() async {
    final data = await supabase.from('users').select();
    if (!mounted) return;
    setState(() {
      users = List<Map<String, dynamic>>.from(data);
    });
  }

  // ================= POPUP BERHASIL =================
  void showBerhasilDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 220,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Berhasil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  // ================= TAMBAH =================
  Future<void> showAddDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const TambahPenggunaDialog(),
    );

    if (result == true && mounted) {
      await fetchUsers();
      showBerhasilDialog();
    }
  }

  // ================= EDIT =================
  Future<void> showEditDialog(Map<String, dynamic> user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EditPenggunaDialog(
        id: user['id'],
        nama: user['nama'],
        role: user['role'],
        email: user['email'],
      ),
    );

    if (result == true && mounted) {
      await fetchUsers();
      showBerhasilDialog();
    }
  }

  // ================= DELETE =================
  Future<void> deleteUser(int id) async {
    await supabase.from('users').delete().eq('id', id);
    if (!mounted) return;
    fetchUsers();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB7D7A8),
        title: const Text(
          'Pengguna',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= SEARCH + ADD =================
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: showAddDialog,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9BBB59),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, i) {
                  final u = users[i];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF6A8F6B),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(u['nama']),
                      subtitle: Text(u['role']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => showEditDialog(u),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteUser(u['id']),
                          ),
                        ],
                      ),
                    ),
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