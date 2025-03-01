import 'package:grsfApp/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const UpdateAllDataApp());
}

class UpdateAllDataApp extends StatelessWidget {
  const UpdateAllDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff16425B)),
      ),
      home: const HomePage()
    );
  }
}

