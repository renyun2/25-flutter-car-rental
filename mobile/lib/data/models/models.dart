import 'package:flutter/foundation.dart';

@immutable
class RentalUser {
  const RentalUser({required this.id, required this.phone, required this.name});

  factory RentalUser.fromJson(Map<String, dynamic> json) => RentalUser(
        id: json['id'] as String,
        phone: json['phone'] as String,
        name: json['name'] as String,
      );

  final String id;
  final String phone;
  final String name;
}

@immutable
class Vehicle {
  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.seats,
    required this.transmission,
    required this.dailyRate,
    required this.hourlyRate,
    required this.deposit,
    this.imageUrl = '',
    this.description = '',
    this.fuelType = '',
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        seats: (json['seats'] as num).toInt(),
        transmission: json['transmission'] as String,
        dailyRate: (json['daily_rate'] as num).toDouble(),
        hourlyRate: (json['hourly_rate'] as num).toDouble(),
        deposit: (json['deposit'] as num).toDouble(),
        imageUrl: json['image_url'] as String? ?? '',
        description: json['description'] as String? ?? '',
        fuelType: json['fuel_type'] as String? ?? '',
      );

  final String id;
  final String brand;
  final String model;
  final int seats;
  final String transmission;
  final double dailyRate;
  final double hourlyRate;
  final double deposit;
  final String imageUrl;
  final String description;
  final String fuelType;

  String get name => '$brand $model';
}

@immutable
class Location {
  const Location({
    required this.id,
    required this.city,
    required this.name,
    required this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json['id'] as String,
        city: json['city'] as String,
        name: json['name'] as String,
        address: json['address'] as String? ?? '',
      );

  final String id;
  final String city;
  final String name;
  final String address;
}

@immutable
class RentalOrder {
  const RentalOrder({
    required this.id,
    required this.vehicleName,
    required this.status,
    required this.pickupAt,
    required this.returnAt,
    required this.totalAmount,
    required this.deposit,
    this.pickupCode,
    this.pickupLocationName = '',
    this.returnLocationName = '',
    this.cancelFee = 0,
    this.refundAmount = 0,
    this.overtimeFee = 0,
    this.fuelFee = 0,
    this.returnBreakdown = const [],
    this.timeline = const [],
    this.imageUrl = '',
  });

  factory RentalOrder.fromJson(Map<String, dynamic> json) => RentalOrder(
        id: json['id'] as String,
        vehicleName: json['vehicle_name'] as String? ?? '',
        status: json['status'] as String,
        pickupAt: json['pickup_at'] as String,
        returnAt: json['return_at'] as String,
        totalAmount: (json['total_amount'] as num).toDouble(),
        deposit: (json['deposit'] as num).toDouble(),
        pickupCode: json['pickup_code'] as String?,
        pickupLocationName: json['pickup_location_name'] as String? ?? '',
        returnLocationName: json['return_location_name'] as String? ?? '',
        cancelFee: (json['cancel_fee'] as num?)?.toDouble() ?? 0,
        refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0,
        overtimeFee: (json['overtime_fee'] as num?)?.toDouble() ?? 0,
        fuelFee: (json['fuel_fee'] as num?)?.toDouble() ?? 0,
        returnBreakdown: (json['return_breakdown'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        timeline: (json['timeline'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        imageUrl: json['image_url'] as String? ?? '',
      );

  final String id;
  final String vehicleName;
  final String status;
  final String pickupAt;
  final String returnAt;
  final double totalAmount;
  final double deposit;
  final String? pickupCode;
  final String pickupLocationName;
  final String returnLocationName;
  final double cancelFee;
  final double refundAmount;
  final double overtimeFee;
  final double fuelFee;
  final List<Map<String, dynamic>> returnBreakdown;
  final List<Map<String, dynamic>> timeline;
  final String imageUrl;
}
