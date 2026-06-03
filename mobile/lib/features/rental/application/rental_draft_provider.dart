import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';

class RentalDraft {
  const RentalDraft({
    this.vehicle,
    this.pickupLocation,
    this.returnLocation,
    this.pickupAt,
    this.returnAt,
    this.insurance = 'none',
    this.couponCode,
    this.lastQuote,
    this.orderId,
  });

  final Vehicle? vehicle;
  final Location? pickupLocation;
  final Location? returnLocation;
  final DateTime? pickupAt;
  final DateTime? returnAt;
  final String insurance;
  final String? couponCode;
  final Map<String, dynamic>? lastQuote;
  final String? orderId;

  RentalDraft copyWith({
    Vehicle? vehicle,
    Location? pickupLocation,
    Location? returnLocation,
    DateTime? pickupAt,
    DateTime? returnAt,
    String? insurance,
    String? couponCode,
    Map<String, dynamic>? lastQuote,
    String? orderId,
  }) =>
      RentalDraft(
        vehicle: vehicle ?? this.vehicle,
        pickupLocation: pickupLocation ?? this.pickupLocation,
        returnLocation: returnLocation ?? this.returnLocation,
        pickupAt: pickupAt ?? this.pickupAt,
        returnAt: returnAt ?? this.returnAt,
        insurance: insurance ?? this.insurance,
        couponCode: couponCode ?? this.couponCode,
        lastQuote: lastQuote ?? this.lastQuote,
        orderId: orderId ?? this.orderId,
      );
}

final rentalDraftProvider = StateProvider<RentalDraft>((_) => const RentalDraft());
