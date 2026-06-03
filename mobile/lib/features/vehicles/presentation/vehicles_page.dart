import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../../shared/presentation/widgets.dart';

class VehiclesPage extends ConsumerStatefulWidget {
  const VehiclesPage({super.key});

  @override
  ConsumerState<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends ConsumerState<VehiclesPage> {
  String? _brand;
  String? _transmission;
  String _sort = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选车')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                DropdownButton<String?>(
                  hint: const Text('品牌'),
                  value: _brand,
                  items: const [
                    DropdownMenuItem(value: '大众', child: Text('大众')),
                    DropdownMenuItem(value: '丰田', child: Text('丰田')),
                    DropdownMenuItem(value: '宝马', child: Text('宝马')),
                  ],
                  onChanged: (v) => setState(() => _brand = v),
                ),
                DropdownButton<String?>(
                  hint: const Text('变速箱'),
                  value: _transmission,
                  items: const [
                    DropdownMenuItem(value: 'auto', child: Text('自动')),
                    DropdownMenuItem(value: 'manual', child: Text('手动')),
                  ],
                  onChanged: (v) => setState(() => _transmission = v),
                ),
                DropdownButton<String>(
                  value: _sort.isEmpty ? null : _sort,
                  hint: const Text('排序'),
                  items: const [
                    DropdownMenuItem(value: 'price_asc', child: Text('价格升序')),
                    DropdownMenuItem(value: 'price_desc', child: Text('价格降序')),
                  ],
                  onChanged: (v) => setState(() => _sort = v ?? ''),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: ref.read(carRentalRepositoryProvider).listVehicles(
                    brand: _brand,
                    transmission: _transmission,
                    sort: _sort.isEmpty ? null : _sort,
                  ),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) return loadingBox();
                if (snap.hasError) return errorBox('${snap.error}');
                final items = snap.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final v = items[i];
                    return ListTile(
                      title: Text(v.name),
                      subtitle: Text('¥${v.dailyRate}/天 · ${v.seats}座 · ${v.transmission}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/vehicle/${v.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
