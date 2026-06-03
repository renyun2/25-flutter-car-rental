import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../../shared/presentation/widgets.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('订单详情')),
      body: FutureBuilder(
        future: ref.read(carRentalRepositoryProvider).getOrder(orderId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return loadingBox();
          if (snap.hasError) return errorBox('${snap.error}');
          final o = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(o.vehicleName, style: Theme.of(context).textTheme.titleLarge),
              Text('状态: ${orderStatusLabel(o.status)}'),
              if (o.pickupCode != null) Text('取车码: ${o.pickupCode}', style: const TextStyle(fontSize: 20)),
              Text('取车: ${o.pickupLocationName}'),
              Text('还车: ${o.returnLocationName}'),
              const Divider(),
              const Text('状态轴'),
              ...o.timeline.map(
                (t) => ListTile(
                  dense: true,
                  title: Text(orderStatusLabel(t['status'] as String)),
                  subtitle: Text('${t['note']}'),
                ),
              ),
              if (o.status == 'pending_payment')
                FilledButton(
                  onPressed: () => context.push('/pay-result?id=$orderId'),
                  child: const Text('去支付'),
                ),
              if (o.status == 'pending_pickup')
                FilledButton(
                  onPressed: () => context.push('/order/$orderId/pickup'),
                  child: const Text('取车确认'),
                ),
              if (o.status == 'in_use')
                FilledButton(
                  onPressed: () => context.push('/order/$orderId/return'),
                  child: const Text('还车结算'),
                ),
              if (['pending_payment', 'pending_pickup'].contains(o.status))
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(carRentalRepositoryProvider).cancelOrder(orderId);
                    if (context.mounted) context.pop();
                  },
                  child: const Text('取消订单'),
                ),
            ],
          );
        },
      ),
    );
  }
}
