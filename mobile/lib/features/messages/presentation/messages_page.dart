import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../../shared/presentation/widgets.dart';

class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: FutureBuilder(
        future: ref.read(carRentalRepositoryProvider).listMessages(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return loadingBox();
          final items = snap.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final m = items[i];
              return ListTile(
                title: Text(m['title'] as String? ?? ''),
                subtitle: Text(m['body'] as String? ?? ''),
                trailing: (m['read'] == true) ? null : const Icon(Icons.circle, size: 8),
              );
            },
          );
        },
      ),
    );
  }
}
