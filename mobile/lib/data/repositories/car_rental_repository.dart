import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/models.dart';

final carRentalRepositoryProvider = Provider<CarRentalRepository>((ref) {
  return CarRentalRepository(ref.watch(dioProvider));
});

class CarRentalRepository {
  CarRentalRepository(this._dio);
  final Dio _dio;

  Future<({String token, RentalUser user})> login(String phone, String password) async {
    final res = await _dio.post('/api/auth/login', data: {'phone': phone, 'password': password});
    return (
      token: res.data['token'] as String,
      user: RentalUser.fromJson(Map<String, dynamic>.from(res.data['user'] as Map)),
    );
  }

  Future<RentalUser> me() async {
    final res = await _dio.get('/api/auth/me');
    return RentalUser.fromJson(Map<String, dynamic>.from(res.data['user'] as Map));
  }

  Future<void> logout() async => _dio.post('/api/auth/logout');

  Future<List<Vehicle>> listVehicles({String? brand, int? seats, String? transmission, String? sort}) async {
    final res = await _dio.get('/api/vehicles', queryParameters: {
      if (brand != null) 'brand': brand,
      if (seats != null) 'seats': seats,
      if (transmission != null) 'transmission': transmission,
      if (sort != null) 'sort': sort,
    });
    return (res.data['items'] as List)
        .map((e) => Vehicle.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Vehicle> getVehicle(String id) async {
    final res = await _dio.get('/api/vehicles/$id');
    return Vehicle.fromJson(Map<String, dynamic>.from(res.data['vehicle'] as Map));
  }

  Future<List<Location>> listLocations({String? city}) async {
    final res = await _dio.get('/api/locations', queryParameters: {if (city != null) 'city': city});
    return (res.data['items'] as List)
        .map((e) => Location.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<String>> listCities() async {
    final res = await _dio.get('/api/locations');
    return (res.data['cities'] as List).map((e) => e.toString()).toList();
  }

  Future<List<Map<String, dynamic>>> getAvailability({
    required String vehicleId,
    required String locationId,
    required String start,
    required String end,
  }) async {
    final res = await _dio.get('/api/availability', queryParameters: {
      'vehicleId': vehicleId,
      'locationId': locationId,
      'start': start,
      'end': end,
    });
    return (res.data['calendar'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> createQuote(Map<String, dynamic> body) async {
    final res = await _dio.post('/api/quotes', data: body);
    return Map<String, dynamic>.from(res.data['quote'] as Map);
  }

  Future<RentalOrder> createOrder(Map<String, dynamic> body) async {
    final res = await _dio.post('/api/orders', data: body);
    return RentalOrder.fromJson(Map<String, dynamic>.from(res.data['order'] as Map));
  }

  Future<List<RentalOrder>> listOrders({String tab = 'active'}) async {
    final res = await _dio.get('/api/orders', queryParameters: {'tab': tab});
    return (res.data['items'] as List)
        .map((e) => RentalOrder.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<RentalOrder> getOrder(String id) async {
    final res = await _dio.get('/api/orders/$id');
    return RentalOrder.fromJson(Map<String, dynamic>.from(res.data['order'] as Map));
  }

  Future<RentalOrder> payOrder(String id) async {
    final res = await _dio.post('/api/orders/$id/pay');
    return RentalOrder.fromJson(Map<String, dynamic>.from(res.data['order'] as Map));
  }

  Future<RentalOrder> cancelOrder(String id) async {
    final res = await _dio.post('/api/orders/$id/cancel');
    return RentalOrder.fromJson(Map<String, dynamic>.from(res.data['order'] as Map));
  }

  Future<RentalOrder> pickupOrder(String id) async {
    final res = await _dio.post('/api/orders/$id/pickup');
    return RentalOrder.fromJson(Map<String, dynamic>.from(res.data['order'] as Map));
  }

  Future<RentalOrder> returnOrder(String id) async {
    final res = await _dio.post('/api/orders/$id/return');
    return RentalOrder.fromJson(Map<String, dynamic>.from(res.data['order'] as Map));
  }

  Future<Map<String, dynamic>> getLicense() async {
    final res = await _dio.get('/api/license');
    return Map<String, dynamic>.from(res.data['license'] as Map);
  }

  Future<Map<String, dynamic>> submitLicense(String realName, String idNumber) async {
    final res = await _dio.post('/api/license', data: {'realName': realName, 'idNumber': idNumber});
    return Map<String, dynamic>.from(res.data['license'] as Map);
  }

  Future<List<Map<String, dynamic>>> listViolations() async {
    final res = await _dio.get('/api/violations');
    return (res.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> getViolation(String id) async {
    final res = await _dio.get('/api/violations/$id');
    return Map<String, dynamic>.from(res.data['violation'] as Map);
  }

  Future<List<Map<String, dynamic>>> listInvoices() async {
    final res = await _dio.get('/api/invoices');
    return (res.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> applyInvoice({String? orderId, required String title, String? taxNo}) async {
    await _dio.post('/api/invoices', data: {
      if (orderId != null) 'orderId': orderId,
      'title': title,
      if (taxNo != null) 'taxNo': taxNo,
    });
  }

  Future<List<Map<String, dynamic>>> listCoupons() async {
    final res = await _dio.get('/api/coupons');
    return (res.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> listTickets() async {
    final res = await _dio.get('/api/tickets');
    return (res.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> createTicket(String subject, String content) async {
    await _dio.post('/api/tickets', data: {'subject': subject, 'content': content});
  }

  Future<List<Map<String, dynamic>>> listMessages() async {
    final res = await _dio.get('/api/messages');
    return (res.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
