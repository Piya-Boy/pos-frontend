import 'package:flutter/material.dart';

import 'core/theme/phius_theme.dart';

class PhiusApp extends StatelessWidget {
  const PhiusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phius Order',
      debugShowCheckedModeBanner: false,
      theme: phiusTheme(),
      home: const Scaffold(body: Center(child: Text('Phius Order'))),
    );
  }
}
