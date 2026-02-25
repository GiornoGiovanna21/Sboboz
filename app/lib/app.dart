// app/lib/app.dart
// Purpose: Root MaterialApp and theme

import 'package:flutter/material.dart';
import 'features/home/presentation/home_page.dart';

class SbobozApp extends StatelessWidget {
  const SbobozApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sboboz 104',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
