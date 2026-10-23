import 'package:flutter/material.dart';

import "core/theme.dart";
import 'screens/splash_screen.dart';

class DeskFlowApp extends StatelessWidget {
  const DeskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
