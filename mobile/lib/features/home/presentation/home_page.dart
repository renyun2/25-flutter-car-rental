import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('快捷租车'),
              subtitle: const Text('浏览车型，选择网点与租期'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/vehicles'),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Banner: 新用户优惠券 NEW50 立减50元'),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(label: const Text('驾照认证'), onPressed: () => context.push('/license')),
              ActionChip(label: const Text('优惠券'), onPressed: () => context.push('/coupons')),
              ActionChip(label: const Text('违章查询'), onPressed: () => context.push('/violations')),
            ],
          ),
        ],
      ),
    );
  }
}
