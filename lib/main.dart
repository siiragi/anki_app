import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const TangoApp());
}

class TangoApp extends StatelessWidget {
  const TangoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '単語暗記アプリ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
