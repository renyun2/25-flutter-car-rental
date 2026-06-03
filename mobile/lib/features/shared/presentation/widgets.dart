import 'package:flutter/material.dart';

String orderStatusLabel(String status) {
  const map = {
    'pending_payment': '待支付',
    'pending_pickup': '待取车',
    'in_use': '使用中',
    'pending_return': '待还车',
    'completed': '已完成',
    'cancelled': '已取消',
  };
  return map[status] ?? status;
}

Widget loadingBox() => const Center(child: CircularProgressIndicator());

Widget errorBox(String msg, {VoidCallback? onRetry}) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg),
          if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
