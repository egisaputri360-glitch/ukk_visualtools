import 'package:flutter/material.dart';
import 'package:krpl/widget/peminjaman_page.dart'; // ← IMPOR INI
import 'package:krpl/widget/riwayat_denda_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SCREEN
import 'screen/splash_screen.dart';
import 'screen/login_screen.dart';
import 'screen/dashboard_screen.dart';

// MASTER PAGE
import 'widget/alat_page.dart';
import 'widget/kategori_page.dart';
// import 'widget/peminjaman_list_page.dart'; // ← HAPUS/JIKA TIDAK DIPAKAI
import 'screen/user_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vefbzsnlhbbwcwomvkbb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZlZmJ6c25saGJid2N3b212a2JiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgzMjc4NjIsImV4cCI6MjA4MzkwMzg2Mn0.QC1nP0NxbwTXLqf-YOBCjWCpDf-VJGQeX01uJ6QLTwQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardPage(),
        '/riwayat': (context) => const RiwayatPage(),

        // MASTER
        '/alat': (context) => const AlatScreen(),
        '/pengguna': (context) => UserPage(),
        '/kategori': (context) => const KategoriPage(),
        '/peminjaman': (context) => const PeminjamanPage(), 
      },
    );
  }
}