import 'package:flutter/material.dart';

import 'screen/splash_screen.dart';
import 'screen/login_screen.dart';
import 'screen/dashboard_screen.dart';
import 'widget/alat_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),

        // MASTER
        '/alat': (context) => AlatScreen(),
        '/pengguna': (context) => DummyPage(title: 'Pengguna'),
        '/kategori': (context) => DummyPage(title: 'Kategori'),
        '/peminjaman': (context) => DummyPage(title: 'Peminjaman'),
      },
    );
  }
}

class DummyPage extends StatelessWidget {
  final String title;
  DummyPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: TextStyle(fontSize: 20)),
      ),
    );
  }
}