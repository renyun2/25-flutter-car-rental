import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../../shared/presentation/widgets.dart';

class ViolationsPage extends ConsumerWidget {
  const ViolationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('违章列表')),
      body: FutureBuilder(
        future: ref.read(carRentalRepositoryProvider).listViolations(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return loadingBox();
          final items = snap.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final v = items[i];
              return ListTile(
                title: Text(v['description'] as String? ?? ''),
                subtitle: Text('¥${v['amount']} · ${v['plate']}'),
                onTap: () => context.push('/violation/${v['id']}'),
              );
            },
          );
        },
      ),
    );
  }
}
