import 'package:flutter/material.dart';

/// Detail Transaksi — implemented in batch 2.
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: Center(child: Text('Transaksi $clientId')),
    );
  }
}
