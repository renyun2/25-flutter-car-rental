import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../../rental/application/rental_draft_provider.dart';
import '../../shared/presentation/widgets.dart';

class CouponsPage extends ConsumerWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('优惠券')),
      body: FutureBuilder(
        future: ref.read(carRentalRepositoryProvider).listCoupons(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return loadingBox();
          final items = snap.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final c = items[i];
              return ListTile(
                title: Text(c['title'] as String? ?? ''),
                subtitle: Text('码: ${c['code']} · 减¥${c['discount']}'),
                trailing: TextButton(
                  child: const Text('使用'),
                  onPressed: () {
                    ref.read(rentalDraftProvider.notifier).state = ref
                        .read(rentalDraftProvider)
                        .copyWith(couponCode: c['code'] as String?);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已选择优惠券')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
