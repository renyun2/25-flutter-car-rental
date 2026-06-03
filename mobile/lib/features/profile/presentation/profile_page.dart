import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider)?.user;
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: ListView(
        children: [
          ListTile(title: Text(user?.name ?? ''), subtitle: Text(user?.phone ?? '')),
          ListTile(title: const Text('驾照认证'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/license')),
          ListTile(title: const Text('违章查询'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/violations')),
          ListTile(title: const Text('发票'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/invoices')),
          ListTile(title: const Text('优惠券'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/coupons')),
          ListTile(title: const Text('客服工单'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/tickets')),
          ListTile(title: const Text('消息'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/messages')),
          ListTile(title: const Text('设置'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/settings')),
        ],
      ),
    );
  }
}
