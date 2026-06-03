import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../../shared/presentation/widgets.dart';

class ViolationDetailPage extends ConsumerWidget {
  const ViolationDetailPage({super.key, required this.violationId});
  final String violationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('违章详情')),
      body: FutureBuilder(
        future: ref.read(carRentalRepositoryProvider).getViolation(violationId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return loadingBox();
          final v = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('描述: ${v['description']}'),
              Text('车牌: ${v['plate']}'),
              Text('金额: ¥${v['amount']}'),
              Text('地点: ${v['location']}'),
              Text('时间: ${v['occurred_at']}'),
              Text('状态: ${v['status']}'),
            ],
          );
        },
      ),
    );
  }
}
