import 'package:flutter/material.dart';
import 'package:omni/core/widgets/app_bottom_nav.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: const Center(child: Text('Goals Placeholder')),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
