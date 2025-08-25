import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OMNI')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Home'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/add'),
                  child: const Text('Add'),
                ),
                ElevatedButton(
                  onPressed: () => context.go('/analytics'),
                  child: const Text('Analytics'),
                ),
                ElevatedButton(
                  onPressed: () => context.go('/goals'),
                  child: const Text('Goals'),
                ),
                ElevatedButton(
                  onPressed: () => context.go('/groups'),
                  child: const Text('Groups'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
