import 'package:flutter/material.dart';
import 'package:omni/core/widgets/app_bottom_nav.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(child: Text('Analytics Placeholder')),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
