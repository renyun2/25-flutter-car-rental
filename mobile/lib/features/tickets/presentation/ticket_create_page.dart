import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/car_rental_repository.dart';

class TicketCreatePage extends ConsumerStatefulWidget {
  const TicketCreatePage({super.key});

  @override
  ConsumerState<TicketCreatePage> createState() => _TicketCreatePageState();
}

class _TicketCreatePageState extends ConsumerState<TicketCreatePage> {
  final _subject = TextEditingController();
  final _content = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建工单')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _subject, decoration: const InputDecoration(labelText: '主题')),
            TextField(
              controller: _content,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '内容'),
            ),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(carRentalRepositoryProvider)
                    .createTicket(_subject.text, _content.text);
                if (mounted) context.pop();
              },
              child: const Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}
