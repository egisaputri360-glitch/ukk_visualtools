import 'package:flutter/material.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  // DATA DUMMY
  final List<Map<String, dynamic>> peminjamanList = [
    {
      "nama": "Chella robiatul",
      "tgl": "26/01/2026",
      "status": "Pengajuan",
      "color": Color(0xFFC1F1FF),
    },
    {
      "nama": "Clarissa Aurelia",
      "tgl": "26/01/2026",
      "status": "Dipinjam",
      "color": Color(0xFFFFAB76),
    },
    {
      "nama": "Melati Tiara",
      "tgl": "26/01/2026",
      "status": "Ditolak",
      "color": Color(0xFFFF4D4D),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              decoration: const BoxDecoration(
                color: Color(0xFFB8D8A0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 28),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/dashboard');
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Peminjaman",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // SEARCH + ADD
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color:
                                Colors.grey.shade200.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 10),
                              Text(
                                "Cari......",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8D8A0),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // JUDUL
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Daftar peminjaman",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ================= LIST =================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: peminjamanList.length,
                itemBuilder: (context, index) {
                  final item = peminjamanList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white, // ⬅️ FIX UTAMA
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["nama"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item["tgl"],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: item["color"],
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                            child: Text(
                              item["status"],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
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