import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB9D7A1),
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            dashboardCard(
              context,
              icon: Icons.people,
              title: 'Pengguna',
              route: '/pengguna',
            ),
            dashboardCard(
              context,
              icon: Icons.work,
              title: 'Alat',
              route: '/alat',
            ),
            dashboardCard(
              context,
              icon: Icons.category,
              title: 'Kategori',
              route: '/kategori',
            ),
            dashboardCard(
              context,
              icon: Icons.assignment,
              title: 'Peminjaman',
              route: '/peminjaman',
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String route}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFB9D7A1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}