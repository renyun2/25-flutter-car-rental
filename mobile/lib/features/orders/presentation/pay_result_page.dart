import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';

class PayResultPage extends ConsumerStatefulWidget {
  const PayResultPage({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<PayResultPage> createState() => _PayResultPageState();
}

class _PayResultPageState extends ConsumerState<PayResultPage> {
  bool _paid = false;

  Future<void> _pay() async {
    await ref.read(carRentalRepositoryProvider).payOrder(widget.orderId);
    setState(() => _paid = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('支付结果')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_paid ? '支付成功 (Mock)' : '待支付 Mock'),
            const SizedBox(height: 16),
            if (!_paid)
              FilledButton(onPressed: _pay, child: const Text('模拟支付')),
            if (_paid) ...[
              FilledButton(
                onPressed: () => context.go('/order/${widget.orderId}'),
                child: const Text('查看订单'),
              ),
              TextButton(onPressed: () => context.go('/orders'), child: const Text('订单列表')),
            ],
          ],
        ),
      ),
    );
  }
}
