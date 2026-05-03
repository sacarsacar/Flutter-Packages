import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() => runApp(const MirrorSkeletonExampleApp());

class MirrorSkeletonExampleApp extends StatelessWidget {
  const MirrorSkeletonExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MirrorSkeleton Examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const HomePage(),
    );
  }
}
