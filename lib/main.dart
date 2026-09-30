import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AlrisyApp());
}

class AlrisyApp extends StatelessWidget {
  const AlrisyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ورشة الريسي للألومنيوم',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // تفعيل اللغة العربية واتجاه اليمين إلى اليسار تلقائياً وبكود مباشر
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
