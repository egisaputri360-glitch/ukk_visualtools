// widget/peminjaman_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pengembalian_page.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> peminjamanList = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchPeminjaman();
  }

  Future<void> fetchPeminjaman() async {
    setState(() => isLoading = true);
    
    try {
      final data = await supabase
          .from('peminjaman')
          .select('*')
          .order('id_peminjaman', ascending: false);
      
      setState(() {
        peminjamanList = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get filteredList {
    if (_searchQuery.isEmpty) return peminjamanList;
    
    return peminjamanList.where((item) {
      final idUser = item['id_user'].toString();
      final status = item['status_peminjaman'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return idUser.contains(query) || status.contains(query);
    }).toList();
  }

  void showForm({Map<String, dynamic>? data}) {
    final idPeminjaman = data?['id_peminjaman'];
    final idUserCtrl = TextEditingController(
      text: data?['id_user']?.toString() ?? ''
    );
    final tglPinjamCtrl = TextEditingController(
      text: data?['tanggal_pinjam']?.toString() ?? ''
    );
    final tglKembaliCtrl = TextEditingController(
      text: data?['tanggal_kembali_rencana']?.toString() ?? ''
    );
    String status = data?['status_peminjaman'] ?? 'aktif';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(data == null ? 'Tambah Peminjaman' : 'Edit Peminjaman'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: idUserCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ID User',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tglPinjamCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Pinjam (YYYY-MM-DD)',
                      hintText: '2024-01-01',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        tglPinjamCtrl.text = 
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tglKembaliCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Kembali Rencana',
                      hintText: '2024-01-08',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        tglKembaliCtrl.text = 
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    items: const [
                      DropdownMenuItem(
                        value: 'aktif',
                        child: Text('Aktif', style: TextStyle(color: Colors.orange)),
                      ),
                      DropdownMenuItem(
                        value: 'selesai',
                        child: Text('Selesai', style: TextStyle(color: Colors.green)),
                      ),
                      DropdownMenuItem(
                        value: 'dibatalkan',
                        child: Text('Dibatalkan', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        status = value;
                        setState(() {});
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Status Peminjaman',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8D8A0),
                ),
                onPressed: () async {
                  if (idUserCtrl.text.isEmpty ||
                      tglPinjamCtrl.text.isEmpty ||
                      tglKembaliCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Semua field wajib diisi')),
                    );
                    return;
                  }

                  try {
                    final Map<String, dynamic> dataToSave = {
                      'id_user': int.tryParse(idUserCtrl.text) ?? 0,
                      'tanggal_pinjam': tglPinjamCtrl.text,
                      'tanggal_kembali_rencana': tglKembaliCtrl.text,
                      'status_peminjaman': status,
                    };

                    if (data == null) {
                      await supabase.from('peminjaman').insert(dataToSave);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Peminjaman berhasil ditambahkan')),
                      );
                    } else {
                      await supabase
                          .from('peminjaman')
                          .update(dataToSave)
                          .eq('id_peminjaman', idPeminjaman);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Peminjaman berhasil diperbarui')),
                      );
                    }

                    Navigator.pop(context);
                    fetchPeminjaman();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan: $e')),
                    );
                  }
                },
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> hapusPeminjaman(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus peminjaman ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await supabase
            .from('peminjaman')
            .delete()
            .eq('id_peminjaman', id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Peminjaman berhasil dihapus')),
        );
        
        fetchPeminjaman();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'aktif':
        return Colors.orange.shade200;
      case 'selesai':
        return Colors.green.shade200;
      case 'dibatalkan':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  Color statusTextColor(String status) {
    switch (status) {
      case 'aktif':
        return Colors.orange.shade800;
      case 'selesai':
        return Colors.green.shade800;
      case 'dibatalkan':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        backgroundColor: const Color(0xFFB8D8A0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text('Peminjaman'),
        backgroundColor: const Color(0xFFB8D8A0),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(Icons.search, color: Colors.grey),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari ID User atau Status...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                ],
              ),
            ),
          ),

          // List Peminjaman
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Belum ada data peminjaman'
                                  : 'Tidak ditemukan hasil pencarian',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchPeminjaman,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final status = item['status_peminjaman']?.toString() ?? 'aktif';
                            final idPeminjaman = item['id_peminjaman'];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'ID Peminjaman: $idPeminjaman',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor(status),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: statusTextColor(status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'ID User: ${item['id_user']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tanggal Pinjam: ${item['tanggal_pinjam']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rencana Kembali: ${item['tanggal_kembali_rencana']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Tombol Pengembalian hanya untuk status aktif
                                        if (status == 'aktif')
                                          IconButton(
                                            icon: const Icon(
                                              Icons.assignment_return,
                                              color: Colors.blue,
                                            ),
                                            tooltip: 'Proses Pengembalian',
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => PengembalianPage(
                                                    idPeminjaman: idPeminjaman,
                                                    tanggalRencanaKembali: 
                                                        item['tanggal_kembali_rencana'],
                                                  ),
                                                ),
                                              );
                                              
                                              if (result == true) {
                                                fetchPeminjaman();
                                              }
                                            },
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.orange),
                                          onPressed: () => showForm(data: item),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => hapusPeminjaman(idPeminjaman),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}