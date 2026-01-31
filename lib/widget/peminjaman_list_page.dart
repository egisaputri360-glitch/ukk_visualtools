import 'package:flutter/material.dart';

class PeminjamanListPage extends StatelessWidget {
  const PeminjamanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB9D7A1),
        title: const Text('Peminjaman'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEARCH
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: 'Cari.....',
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Daftar peminjaman',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // CARD DETAIL (EXPANDED)
            detailPeminjamanCard(),

            statusOnlyCard(
              nama: 'Clarissa Aurelia',
              tanggal: '26/01/2026',
              status: 'Dipinjam',
              warna: Colors.orangeAccent,
            ),

            statusOnlyCard(
              nama: 'Melati Tiara',
              tanggal: '26/01/2026',
              status: 'Ditolak',
              warna: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  // CARD DETAIL PEMINJAMAN
  Widget detailPeminjamanCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB9D7A1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chella rohbatul',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            '26/01/2026',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const Divider(),

          const Text(
            'Alat',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          alatRow('Kamera Sony'),
          alatRow('Gimbal Stabilizer'),

          const Divider(),

          const Text(
            'Kembali',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            '30/01/2026',
            style: TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pengajuan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // ROW ALAT
  Widget alatRow(String namaAlat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(namaAlat),
          const Text('|'),
        ],
      ),
    );
  }

  // CARD STATUS SAJA
  Widget statusOnlyCard({
    required String nama,
    required String tanggal,
    required String status,
    required Color warna,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB9D7A1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nama,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                tanggal,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: warna,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}