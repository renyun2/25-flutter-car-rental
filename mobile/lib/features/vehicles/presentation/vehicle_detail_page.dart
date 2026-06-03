import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../../rental/application/rental_draft_provider.dart';
import '../../shared/presentation/widgets.dart';

class VehicleDetailPage extends ConsumerWidget {
  const VehicleDetailPage({super.key, required this.vehicleId});
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('车型详情')),
      body: FutureBuilder(
        future: ref.read(carRentalRepositoryProvider).getVehicle(vehicleId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return loadingBox();
          if (snap.hasError) return errorBox('${snap.error}');
          final v = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.name, style: Theme.of(context).textTheme.headlineSmall),
                Text(v.description),
                const SizedBox(height: 8),
                Text('日租金: ¥${v.dailyRate}'),
                Text('时租金: ¥${v.hourlyRate}'),
                Text('押金: ¥${v.deposit}'),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    ref.read(rentalDraftProvider.notifier).state =
                        ref.read(rentalDraftProvider).copyWith(vehicle: v);
                    context.push('/locations');
                  },
                  child: const Text('选择网点'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
