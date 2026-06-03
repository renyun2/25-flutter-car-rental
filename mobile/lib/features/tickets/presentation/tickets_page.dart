import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../../shared/presentation/widgets.dart';

class TicketsPage extends ConsumerWidget {
  const TicketsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('客服工单'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/ticket/create'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: ref.read(carRentalRepositoryProvider).listTickets(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return loadingBox();
          final items = snap.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final t = items[i];
              return ListTile(
                title: Text(t['subject'] as String? ?? ''),
                subtitle: Text('${t['status']} · ${t['content']}'),
              );
            },
          );
        },
      ),
    );
  }
}
