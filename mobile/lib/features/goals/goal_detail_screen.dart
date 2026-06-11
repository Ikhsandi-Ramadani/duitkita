import 'package:flutter/material.dart';

/// Detail Kantong — implemented in batch 4.
class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final int goalId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kantong')),
      body: Center(child: Text('Kantong $goalId')),
    );
  }
}
