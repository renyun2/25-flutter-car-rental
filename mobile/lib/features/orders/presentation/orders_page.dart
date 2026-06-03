import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../../shared/presentation/widgets.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: '进行中'), Tab(text: '历史')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _OrderList(tab: 'active'),
          _OrderList(tab: 'history'),
        ],
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  const _OrderList({required this.tab});
  final String tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(carRentalRepositoryProvider).listOrders(tab: tab),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return loadingBox();
        if (snap.hasError) return errorBox('${snap.error}');
        final items = snap.data!;
        if (items.isEmpty) return const Center(child: Text('暂无订单'));
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final o = items[i];
            return ListTile(
              title: Text(o.vehicleName),
              subtitle: Text('${orderStatusLabel(o.status)} · ¥${o.totalAmount}'),
              onTap: () => context.push('/order/${o.id}'),
            );
          },
        );
      },
    );
  }
}
