import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';

class ReturnPage extends ConsumerWidget {
  const ReturnPage({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('还车结算')),
      body: FutureBuilder(
        future: ref.read(carRentalRepositoryProvider).getOrder(orderId),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final o = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('费用明细 (Mock 超时费/油费)'),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(value: o.totalAmount, title: '租金', color: Colors.blue),
                        PieChartSectionData(value: 45, title: '超时', color: Colors.orange),
                        PieChartSectionData(value: 30, title: '油费', color: Colors.green),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    await ref.read(carRentalRepositoryProvider).returnOrder(orderId);
                    if (context.mounted) context.go('/order/$orderId');
                  },
                  child: const Text('确认还车并结算'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
