import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:krpl/service/alat_service.dart';

const primaryGreen = Color(0xFFB2CF99);
const bgSoft = Color(0xFFF6FAF4);

/* ================= SCREEN ================= */

class AlatScreen extends StatefulWidget {
  const AlatScreen({super.key});

  @override
  State<AlatScreen> createState() => _AlatScreenState();
}

class _AlatScreenState extends State<AlatScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Alat> alatList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAlat();
  }

  Future<void> _loadAlat() async {
    setState(() => isLoading = true);
    final data = await AlatService.getAlat();

    setState(() {
      alatList = data.map((e) {
        return Alat(
          idAlat: e['id_alat'],
          name: e['nama_alat'],
          category: e['id_kategori'].toString(),
          kondisi: e['kondisi'] ?? 'Baik', // Ambil kondisi dari database
          imageUrl: e['image_url'],
        );
      }).toList();
      isLoading = false;
    });
  }

  List<Alat> get filteredAlat {
    if (searchController.text.isEmpty) return alatList;
    final q = searchController.text.toLowerCase();
    return alatList
        .where((a) => a.name.toLowerCase().contains(q))
        .toList();
  }

  void _openDialog({Alat? alat}) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => TambahEditDialog(
        isEdit: alat != null,
        initialAlat: alat,
      ),
    ).then((res) {
      if (res == true) _loadAlat();
    });
  }

  Future<void> _showDelete(Alat alat) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Alat'),
        content: Text('Yakin hapus "${alat.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await AlatService.deleteAlat(
                idAlat: alat.idAlat,
                imageUrl: alat.imageUrl,
              );
              Navigator.pop(context);
              _loadAlat();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryGreen,
        title: const Text(
          'Data Alat',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Search Bar dengan Add Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari alat...',
                        prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => _openDialog(),
                    icon: const Icon(Icons.add, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(50, 50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Info Jumlah Alat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Total Alat: ${alatList.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (searchController.text.isNotEmpty)
                  Text(
                    'Ditemukan: ${filteredAlat.length}',
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: primaryGreen),
                        SizedBox(height: 10),
                        Text(
                          'Memuat data alat...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : filteredAlat.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchController.text.isEmpty
                                  ? 'Belum ada alat'
                                  : 'Alat tidak ditemukan',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              searchController.text.isEmpty
                                  ? 'Tambahkan alat baru dengan tombol +'
                                  : 'Coba kata kunci lain',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: filteredAlat.length,
                        itemBuilder: (context, index) {
                          final alat = filteredAlat[index];
                          return AlatCard(
                            alat: alat,
                            onEdit: () => _openDialog(alat: alat),
                            onDelete: () => _showDelete(alat),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/* ================= DIALOG ================= */

class TambahEditDialog extends StatefulWidget {
  final bool isEdit;
  final Alat? initialAlat;

  const TambahEditDialog({
    super.key,
    required this.isEdit,
    this.initialAlat,
  });

  @override
  State<TambahEditDialog> createState() => _TambahEditDialogState();
}

class _TambahEditDialogState extends State<TambahEditDialog> {
  late TextEditingController namaC;
  late String kondisi;
  late TextEditingController jumlahC;

  XFile? mobileImage;
  Uint8List? webImage;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.initialAlat?.name ?? '');
    kondisi = widget.initialAlat?.kondisi ?? 'Baik';
    jumlahC = TextEditingController(text: '1');
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      final res = await FilePicker.platform.pickFiles(type: FileType.image);
      if (res != null) webImage = res.files.first.bytes;
    } else {
      final res = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (res != null) mobileImage = res;
    }
    setState(() {});
  }

  Future<void> _save() async {
    if (namaC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama alat harus diisi')),
      );
      return;
    }
    
    setState(() => loading = true);

    final jumlah = int.tryParse(jumlahC.text) ?? 1;
    final status = kondisi == 'Baik' ? 'tersedia' : 'rusak';
    String? imageUrl = widget.initialAlat?.imageUrl;

    if (mobileImage != null || webImage != null) {
      imageUrl = await AlatService.uploadImage(
        mobileFile: mobileImage != null ? File(mobileImage!.path) : null,
        webBytes: webImage,
        namaAlat: namaC.text,
      );
    }

    try {
      if (widget.isEdit) {
        await AlatService.updateAlat(
          idAlat: widget.initialAlat!.idAlat,
          idKategori: 1,
          nama: namaC.text,
          jumlah: jumlah,
          kondisi: kondisi,
          status: status,
          imageUrl: imageUrl,
        );
      } else {
        await AlatService.insertAlat(
          idKategori: 1,
          nama: namaC.text,
          jumlah: jumlah,
          kondisi: kondisi,
          status: status,
          imageUrl: imageUrl,
        );
      }

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.isEdit ? 'Edit' : 'Tambah'} alat berhasil'),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.isEdit ? Icons.edit : Icons.add,
                  color: primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isEdit ? 'Edit Alat' : 'Tambah Alat Baru',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Preview Image
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: bgSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryGreen.withOpacity(0.3), width: 2),
                  ),
                  child: mobileImage != null || webImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: kIsWeb && webImage != null
                              ? Image.memory(webImage!, fit: BoxFit.cover)
                              : mobileImage != null
                                  ? Image.file(File(mobileImage!.path), fit: BoxFit.cover)
                                  : null,
                        )
                      : widget.initialAlat?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                widget.initialAlat!.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, color: primaryGreen.withOpacity(0.5)),
                                const SizedBox(height: 4),
                                Text(
                                  'Tambah Gambar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: primaryGreen.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            TextField(
              controller: namaC,
              decoration: InputDecoration(
                labelText: 'Nama Alat',
                prefixIcon: const Icon(Icons.label_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: jumlahC,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      prefixIcon: const Icon(Icons.numbers),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: kondisi,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        items: const [
                          DropdownMenuItem(
                            value: 'Baik',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Text('Baik'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Rusak',
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Rusak'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => kondisi = v!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: loading ? null : _save,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        widget.isEdit ? 'Simpan Perubahan' : 'Tambah Alat',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class Alat {
  final int idAlat;
  final String name;
  final String category;
  final String kondisi; // 'Baik' atau 'Rusak'
  final String? imageUrl;

  Alat({
    required this.idAlat,
    required this.name,
    required this.category,
    required this.kondisi,
    this.imageUrl,
  });
}


class AlatCard extends StatelessWidget {
  final Alat alat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlatCard({
    super.key,
    required this.alat,
    required this.onEdit,
    required this.onDelete,
  });

  Color getConditionColor(String kondisi) {
    return kondisi == 'Baik' ? Colors.green : Colors.red;
  }

  IconData getConditionIcon(String kondisi) {
    return kondisi == 'Baik' ? Icons.check_circle : Icons.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Gambar
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgSoft,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: alat.imageUrl != null && alat.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      child: Image.network(
                        alat.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 50,
                              color: primaryGreen.withOpacity(0.5),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: primaryGreen,
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 50,
                        color: primaryGreen.withOpacity(0.5),
                      ),
                    ),
            ),
          ),
          
          // Bagian Info
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nama Alat
                  Text(
                    alat.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  
                  // Kondisi dan Tombol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge Kondisi
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: getConditionColor(alat.kondisi).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: getConditionColor(alat.kondisi),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              getConditionIcon(alat.kondisi),
                              size: 12,
                              color: getConditionColor(alat.kondisi),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              alat.kondisi,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: getConditionColor(alat.kondisi),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Tombol Aksi
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Color.fromARGB(255, 0, 0, 0)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 30,
                                minHeight: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 7, 7, 7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete_outline, size: 18, color: Color.fromARGB(255, 10, 10, 10)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 30,
                                minHeight: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}