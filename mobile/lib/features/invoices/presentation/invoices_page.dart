import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../../shared/presentation/widgets.dart';

class InvoicesPage extends ConsumerWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发票记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/invoices/apply'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: ref.read(carRentalRepositoryProvider).listInvoices(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return loadingBox();
          final items = snap.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final inv = items[i];
              return ListTile(
                title: Text(inv['title'] as String? ?? ''),
                subtitle: Text('¥${inv['amount']} · ${inv['status']}'),
              );
            },
          );
        },
      ),
    );
  }
}
