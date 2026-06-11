import 'package:flutter/material.dart';

/// Detail Utang/Piutang — implemented in batch 4.
class DebtDetailScreen extends StatelessWidget {
  const DebtDetailScreen({super.key, required this.debtId});

  final int debtId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Utang')),
      body: Center(child: Text('Utang $debtId')),
    );
  }
}
