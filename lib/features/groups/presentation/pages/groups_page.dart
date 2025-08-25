import 'package:flutter/material.dart';
import 'package:omni/core/widgets/app_bottom_nav.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: const Center(child: Text('Groups Placeholder')),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}
