import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../application/rental_draft_provider.dart';
import '../../shared/presentation/widgets.dart';

class QuotePage extends ConsumerStatefulWidget {
  const QuotePage({super.key});

  @override
  ConsumerState<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends ConsumerState<QuotePage> {
  Map<String, dynamic>? _quote;
  String _insurance = 'none';
  bool _loading = false;

  String _iso(DateTime dt) => dt.toIso8601String().substring(0, 19);

  Future<void> _fetchQuote() async {
    final draft = ref.read(rentalDraftProvider);
    final v = draft.vehicle;
    final loc = draft.pickupLocation;
    if (v == null || loc == null || draft.pickupAt == null || draft.returnAt == null) return;
    setState(() => _loading = true);
    try {
      final q = await ref.read(carRentalRepositoryProvider).createQuote({
        'vehicleId': v.id,
        'pickupLocationId': loc.id,
        'pickupAt': _iso(draft.pickupAt!),
        'returnAt': _iso(draft.returnAt!),
        'insurance': _insurance,
        if (draft.couponCode != null) 'couponCode': draft.couponCode,
      });
      ref.read(rentalDraftProvider.notifier).state =
          draft.copyWith(insurance: _insurance, lastQuote: q);
      setState(() => _quote = q);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchQuote());
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(rentalDraftProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('报价')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('车型: ${draft.vehicle?.name ?? ""}'),
            const Text('保险选项'),
            RadioListTile(
              title: const Text('无'),
              value: 'none',
              groupValue: _insurance,
              onChanged: (v) {
                setState(() => _insurance = v!);
                _fetchQuote();
              },
            ),
            RadioListTile(
              title: const Text('基础险 +30'),
              value: 'basic',
              groupValue: _insurance,
              onChanged: (v) {
                setState(() => _insurance = v!);
                _fetchQuote();
              },
            ),
            RadioListTile(
              title: const Text('全险 +80'),
              value: 'full',
              groupValue: _insurance,
              onChanged: (v) {
                setState(() => _insurance = v!);
                _fetchQuote();
              },
            ),
            if (_loading) loadingBox() else if (_quote != null) ...[
              Text('租期: ${_quote!['hours']} 小时'),
              Text('租金: ¥${_quote!['rentalFee']}'),
              Text('合计: ¥${_quote!['total']}'),
              Text('押金: ¥${_quote!['deposit']}'),
            ],
            const Spacer(),
            FilledButton(
              onPressed: _quote == null ? null : () => context.push('/order/confirm'),
              child: const Text('确认订单'),
            ),
          ],
        ),
      ),
    );
  }
}
