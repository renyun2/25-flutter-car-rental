import 'package:car_rental/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Vehicle fromJson', () {
    final v = Vehicle.fromJson({
      'id': '1',
      'brand': '大众',
      'model': '朗逸',
      'seats': 5,
      'transmission': 'auto',
      'daily_rate': 200,
      'hourly_rate': 25,
      'deposit': 400,
    });
    expect(v.name, '大众 朗逸');
    expect(v.dailyRate, 200);
  });

  test('orderStatus mapping', () {
    final o = RentalOrder.fromJson({
      'id': 'o1',
      'vehicle_name': '大众 朗逸',
      'status': 'pending_pickup',
      'pickup_at': '2026-06-01T10:00:00',
      'return_at': '2026-06-02T10:00:00',
      'total_amount': 300,
      'deposit': 400,
      'pickup_code': '123456',
    });
    expect(o.pickupCode, '123456');
  });
}
