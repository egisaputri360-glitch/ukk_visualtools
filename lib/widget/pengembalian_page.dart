import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'peminjaman_page.dart';

class PengembalianPage extends StatefulWidget {
  final int idPeminjaman;
  final String tanggalRencanaKembali;

  const PengembalianPage({
    super.key,
    required this.idPeminjaman,
    required this.tanggalRencanaKembali,
  });

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  final supabase = Supabase.instance.client;
  
  Map<String, dynamic>? peminjamanData;
  List<dynamic> riwayatPengembalian = [];
  List<dynamic>? alatDipinjam;
  
  final TextEditingController _kondisiController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  DateTime? _tanggalPengembalian;
  String _kondisiAlat = 'baik';
  bool _isLoading = true;
  bool _isSubmitting = false;
  
  int denda = 0;
  int keterlambatanHari = 0;
  
  final List<String> _kondisiOptions = ['baik', 'rusak_ringan', 'rusak_berat'];

  @override
  void initState() {
    super.initState();
    _tanggalPengembalian = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final peminjamanResult = await supabase
          .from('peminjaman')
          .select()
          .eq('id_peminjaman', widget.idPeminjaman)
          .single();
      
      setState(() => peminjamanData = peminjamanResult);
      
      if (peminjamanResult['id_user'] != null) {
        final userResult = await supabase
            .from('users')
            .select('nama')
            .eq('id', peminjamanResult['id_user'])
            .maybeSingle();
        
        if (userResult != null) {
          peminjamanData!['nama_user'] = userResult['nama'];
        }
      }
      
      final riwayatResult = await supabase
          .from('pengembalian')
          .select()
          .eq('id_peminjaman', widget.idPeminjaman)
          .order('tanggal_pengembalian', ascending: false);
      
      setState(() => riwayatPengembalian = riwayatResult);
      
      final alatResult = await supabase
          .from('detail_peminjaman')
          .select('''
            id_alat,
            alat:alat_alat (nama_alat, kategori)
          ''')
          .eq('id_peminjaman', widget.idPeminjaman);
      
      setState(() => alatDipinjam = alatResult);
      
      _hitungDenda();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _hitungDenda() {
    if (peminjamanData == null) return;
    
    final tglRencanaKembali = DateTime.tryParse(widget.tanggalRencanaKembali);
    final tglPengembalian = _tanggalPengembalian ?? DateTime.now();
    
    if (tglRencanaKembali != null && tglPengembalian.isAfter(tglRencanaKembali)) {
      final selisih = tglPengembalian.difference(tglRencanaKembali).inDays;
      setState(() {
        keterlambatanHari = selisih > 0 ? selisih : 0;
        denda = keterlambatanHari * 10000;
      });
    } else {
      setState(() {
        keterlambatanHari = 0;
        denda = 0;
      });
    }
  }

  Future<void> _pilihTanggal() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null) {
      setState(() {
        _tanggalPengembalian = pickedDate;
        _hitungDenda();
      });
    }
  }

  // ================ PERBAIKAN: METHOD SEDERHANA TANPA ERROR ================
  Future<void> _prosesPengembalian() async {
    if (_tanggalPengembalian == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal pengembalian terlebih dahulu')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      // HANYA KOLOM YANG PASTI ADA DI DATABASE
      Map<String, dynamic> data = {
        'id_peminjaman': widget.idPeminjaman,
        'tanggal_pengembalian': _tanggalPengembalian!.toIso8601String(),
        'kondisi_alat': _kondisiAlat,
        'status_pengembalian': 'selesai',
      };
      
      // Tambahkan keterangan hanya jika tidak kosong
      if (_keteranganController.text.trim().isNotEmpty) {
        data['keterangan'] = _keteranganController.text.trim();
      }
      
      // TIDAK MENAMBAHKAN KOLOM 'denda' dan 'keterlambatan_hari'
      // Karena kolom tersebut belum ada di database
      
      // 1. Simpan data pengembalian
      await supabase.from('pengembalian').insert(data);
      
      // 2. Update status peminjaman
      await supabase
          .from('peminjaman')
          .update({'status_peminjaman': 'selesai'})
          .eq('id_peminjaman', widget.idPeminjaman);
      
      // 3. Update status alat jika kondisi baik
      if (_kondisiAlat == 'baik' && alatDipinjam != null) {
        for (var alat in alatDipinjam!) {
          await supabase
              .from('alat_alat')
              .update({'status': 'tersedia'})
              .eq('id_alat', alat['id_alat']);
        }
      }
      
      // 4. Tampilkan pesan sukses dengan info denda
      String message = '✅ Pengembalian berhasil diproses';
      if (denda > 0) {
        message += '\nDenda: ${_formatRupiah(denda)} (dicatat manual)';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // 5. Refresh data
      await _loadData();
      
    } catch (e) {
      print('Error: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Gagal memproses pengembalian'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _formatKondisi(String kondisi) {
    switch (kondisi) {
      case 'baik':
        return 'Baik';
      case 'rusak_ringan':
        return 'Rusak Ringan';
      case 'rusak_berat':
        return 'Rusak Berat';
      default:
        return kondisi;
    }
  }

  Color _getKondisiColor(String kondisi) {
    switch (kondisi) {
      case 'baik':
        return Colors.green;
      case 'rusak_ringan':
        return Colors.orange;
      case 'rusak_berat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTanggal(String? dateString) {
    if (dateString == null) return '-';
    final date = DateTime.tryParse(dateString);
    if (date == null) return dateString;
    
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian Alat'),
        backgroundColor: const Color(0xFFB8D8A0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (peminjamanData != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Peminjaman #${widget.idPeminjaman}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  peminjamanData!['nama_user'] ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Pinjam: ${_formatTanggal(peminjamanData!['tanggal_pinjam'])}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Rencana Kembali: ${_formatTanggal(widget.tanggalRencanaKembali)}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          const Text(
                            'Tanggal Pengembalian',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          InkWell(
                            onTap: _pilihTanggal,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, 
                                      color: Colors.grey, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatTanggal(
                                          _tanggalPengembalian?.toIso8601String()),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  if (_tanggalPengembalian != null)
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      onPressed: _pilihTanggal,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          const Text(
                            'Kondisi Alat',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _kondisiOptions.map((kondisi) {
                              final isSelected = _kondisiAlat == kondisi;
                              return ChoiceChip(
                                label: Text(_formatKondisi(kondisi)),
                                selected: isSelected,
                                selectedColor: _getKondisiColor(kondisi),
                                backgroundColor: Colors.grey.shade200,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    _kondisiAlat = kondisi;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          TextField(
                            controller: _keteranganController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Keterangan (opsional)',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // PERHITUNGAN DENDA (HANYA TAMPILAN, TIDAK DISIMPAN)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: denda > 0 
                                  ? Colors.orange.shade50 
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: denda > 0 
                                    ? Colors.orange.shade200 
                                    : Colors.green.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      denda > 0 ? Icons.warning : Icons.check_circle,
                                      color: denda > 0 ? Colors.orange : Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      denda > 0 ? 'KETERLAMBATAN' : 'TEPAT WAKTU',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: denda > 0 ? Colors.orange : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                if (keterlambatanHari > 0)
                                  Text(
                                    'Terlambat: $keterlambatanHari hari',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                
                                const SizedBox(height: 4),
                                
                                Text(
                                  'Perhitungan Denda: ${_formatRupiah(denda)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: denda > 0 ? Colors.red : Colors.green,
                                  ),
                                ),
                                
                                if (denda > 0)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      '* Denda akan dicatat manual oleh admin',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (peminjamanData != null && 
                                        peminjamanData!['status_peminjaman'] == 'aktif' && 
                                        !_isSubmitting)
                                  ? _prosesPengembalian
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (peminjamanData != null && 
                                        peminjamanData!['status_peminjaman'] == 'aktif')
                                    ? const Color(0xFFB8D8A0)
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      peminjamanData != null && 
                                      peminjamanData!['status_peminjaman'] == 'aktif'
                                          ? 'KEMBALIKAN'
                                          : 'SUDAH DIKEMBALIKAN',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          
                          if (peminjamanData != null && 
                              peminjamanData!['status_peminjaman'] != 'aktif')
                            const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Text(
                                'Alat sudah dikembalikan sebelumnya',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (riwayatPengembalian.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Riwayat Pengembalian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ...riwayatPengembalian.map((riwayat) {
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
                                children: [
                                  const Icon(Icons.date_range, 
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTanggal(riwayat['tanggal_pengembalian']),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getKondisiColor(
                                              riwayat['kondisi_alat'] ?? 'baik')
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _getKondisiColor(
                                            riwayat['kondisi_alat'] ?? 'baik'),
                                      ),
                                    ),
                                    child: Text(
                                      _formatKondisi(riwayat['kondisi_alat'] ?? 'baik'),
                                      style: TextStyle(
                                        color: _getKondisiColor(
                                            riwayat['kondisi_alat'] ?? 'baik'),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              if (riwayat['keterangan'] != null && 
                                  riwayat['keterangan'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Catatan: ${riwayat['keterangan']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
    );
  }
}