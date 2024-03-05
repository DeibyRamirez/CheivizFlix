// ignore_for_file: deprecated_member_use

import 'package:cheivizflix/Principal.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CheivizFlix());
}

class CheivizFlix extends StatelessWidget {
  const CheivizFlix({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ChevizFliz',
      debugShowCheckedModeBanner: false,
      home: Principal(),
    );
  }
}
