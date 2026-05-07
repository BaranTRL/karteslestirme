import 'package:flutter/material.dart';

import 'ui/pages/home_page.dart';

class KartEsleslestirmeApp extends StatelessWidget {
  const KartEsleslestirmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kart Eşleştirme',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
