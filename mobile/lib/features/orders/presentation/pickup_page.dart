import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';

class PickupPage extends ConsumerWidget {
  const PickupPage({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('取车确认')),
      body: FutureBuilder(
        future: ref.read(carRentalRepositoryProvider).getOrder(orderId),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final o = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('取车码（6位）: ${o.pickupCode ?? "支付后生成"}', style: const TextStyle(fontSize: 24)),
                const Text('请在网点工作人员处确认取车'),
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    await ref.read(carRentalRepositoryProvider).pickupOrder(orderId);
                    if (context.mounted) context.go('/order/$orderId');
                  },
                  child: const Text('确认已取车'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
