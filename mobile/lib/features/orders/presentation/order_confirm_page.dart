import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../../rental/application/rental_draft_provider.dart';
import '../../shared/presentation/widgets.dart';

class OrderConfirmPage extends ConsumerStatefulWidget {
  const OrderConfirmPage({super.key});

  @override
  ConsumerState<OrderConfirmPage> createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends ConsumerState<OrderConfirmPage> {
  bool _loading = false;

  String _iso(DateTime dt) => dt.toIso8601String().substring(0, 19);

  Future<void> _submit() async {
    final draft = ref.read(rentalDraftProvider);
    final v = draft.vehicle;
    final pickup = draft.pickupLocation;
    final ret = draft.returnLocation;
    if (v == null || pickup == null || ret == null || draft.pickupAt == null || draft.returnAt == null) {
      return;
    }
    setState(() => _loading = true);
    try {
      final order = await ref.read(carRentalRepositoryProvider).createOrder({
        'vehicleId': v.id,
        'pickupLocationId': pickup.id,
        'returnLocationId': ret.id,
        'pickupAt': _iso(draft.pickupAt!),
        'returnAt': _iso(draft.returnAt!),
        'insurance': draft.insurance,
        if (draft.couponCode != null) 'couponCode': draft.couponCode,
      });
      ref.read(rentalDraftProvider.notifier).state = draft.copyWith(orderId: order.id);
      if (mounted) context.go('/pay-result?id=${order.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(rentalDraftProvider);
    final q = draft.lastQuote;
    return Scaffold(
      appBar: AppBar(title: const Text('确认订单')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${draft.vehicle?.name}'),
            Text('取车: ${draft.pickupLocation?.name}'),
            Text('还车: ${draft.returnLocation?.name}'),
            if (q != null) Text('应付: ¥${q['total']} (含押金 ¥${q['deposit']})'),
            const Spacer(),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator() : const Text('提交订单'),
            ),
          ],
        ),
      ),
    );
  }
}
