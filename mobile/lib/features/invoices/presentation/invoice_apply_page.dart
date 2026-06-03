import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';

class InvoiceApplyPage extends ConsumerStatefulWidget {
  const InvoiceApplyPage({super.key});

  @override
  ConsumerState<InvoiceApplyPage> createState() => _InvoiceApplyPageState();
}

class _InvoiceApplyPageState extends ConsumerState<InvoiceApplyPage> {
  final _title = TextEditingController();
  final _tax = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发票申请')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: '发票抬头')),
            TextField(controller: _tax, decoration: const InputDecoration(labelText: '税号')),
            FilledButton(
              onPressed: () async {
                await ref.read(carRentalRepositoryProvider).applyInvoice(
                      title: _title.text,
                      taxNo: _tax.text,
                    );
                if (mounted) context.pop();
              },
              child: const Text('提交申请'),
            ),
          ],
        ),
      ),
    );
  }
}
