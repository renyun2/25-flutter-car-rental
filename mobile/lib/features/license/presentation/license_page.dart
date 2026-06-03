import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/car_rental_repository.dart';

class DriverLicensePage extends ConsumerStatefulWidget {
  const DriverLicensePage({super.key});

  @override
  ConsumerState<DriverLicensePage> createState() => _DriverLicensePageState();
}

class _DriverLicensePageState extends ConsumerState<DriverLicensePage> {
  final _name = TextEditingController();
  final _id = TextEditingController();
  Map<String, dynamic>? _lic;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lic = await ref.read(carRentalRepositoryProvider).getLicense();
    setState(() {
      _lic = lic;
      _name.text = lic['real_name'] as String? ?? '';
      _id.text = lic['id_number'] as String? ?? '';
    });
  }

  String _statusLabel(String? s) {
    const m = {
      'none': '未认证',
      'pending': '审核中',
      'approved': '已通过',
      'rejected': '已驳回',
    };
    return m[s] ?? s ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('驾照认证')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('状态: ${_statusLabel(_lic?['status'] as String?)}'),
            TextField(controller: _name, decoration: const InputDecoration(labelText: '姓名')),
            TextField(controller: _id, decoration: const InputDecoration(labelText: '证件号')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await ref.read(carRentalRepositoryProvider).submitLicense(_name.text, _id.text);
                await _load();
              },
              child: const Text('提交认证 (Mock)'),
            ),
          ],
        ),
      ),
    );
  }
}
