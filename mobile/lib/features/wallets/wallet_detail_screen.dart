import 'package:flutter/material.dart';

/// Detail Dompet — implemented in batch 3.
class WalletDetailScreen extends StatelessWidget {
  const WalletDetailScreen({super.key, required this.walletId});

  final int walletId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Dompet')),
      body: Center(child: Text('Dompet $walletId')),
    );
  }
}
