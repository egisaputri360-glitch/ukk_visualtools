import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AlatScreen(),
  ));
}

class AlatScreen extends StatefulWidget {
  const AlatScreen({super.key});

  @override
  State<AlatScreen> createState() => _AlatScreenState();
}

class _AlatScreenState extends State<AlatScreen> {
  final TextEditingController searchController = TextEditingController();

  // Data alat sample
  List<Alat> alatList = [
    Alat('Camera Sony', 'Alat digital', StatusAlat.bagus),
    Alat('Gimbal Stabilizer', 'Alat digital', StatusAlat.bagus),
    Alat('Cat Warna', 'Alat Gambar', StatusAlat.rusak),
    Alat('Sketch Book', 'Alat Gambar', StatusAlat.rusak),
    Alat('Drawing Pen', 'Alat Gambar', StatusAlat.rusak),
    Alat('Sketch Book', 'Alat Gambar', StatusAlat.bagus),
  ];

  // Filter hasil pencarian
  List<Alat> get filteredAlat {
    if (searchController.text.isEmpty) {
      return alatList;
    } else {
      return alatList
          .where((a) =>
              a.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
              a.category.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB9D7A1), // warna hijau muda background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header "Alat"
              Row(
                children: [
                  const Text(
                    'Alat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  // placeholder untuk simetri rounding container
                  Container(width: 40),
                ],
              ),

              const SizedBox(height: 16),

              // Search + tombol + + filter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari....',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Tombol plus +
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA8C98A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.black),
                  ),

                  const SizedBox(width: 8),

                  // Icon filter
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_alt, color: Colors.black),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Grid alat
              Expanded(
                child: GridView.builder(
                  itemCount: filteredAlat.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final alat = filteredAlat[index];
                    return AlatCard(alat: alat);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum StatusAlat { bagus, rusak }

class Alat {
  final String name;
  final String category;
  final StatusAlat status;

  Alat(this.name, this.category, this.status);
}

class AlatCard extends StatelessWidget {
  final Alat alat;

  const AlatCard({super.key, required this.alat});

  Color get statusColor {
    switch (alat.status) {
      case StatusAlat.bagus:
        return Colors.greenAccent.shade400;
      case StatusAlat.rusak:
        return Colors.redAccent.shade400;
    }
  }

  String get statusText {
    switch (alat.status) {
      case StatusAlat.bagus:
        return 'Baik';
      case StatusAlat.rusak:
        return 'Rusak';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Nama alat
          Text(
            alat.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),

          // Kategori alat
          Text(
            alat.category,
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54),
          ),

          const Spacer(),

          // Icon edit & delete
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  // TODO: aksi edit
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () {
                  // TODO: aksi delete
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}