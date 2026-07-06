import 'package:flutter/foundation.dart';

import '../../../core/utils/money.dart';

/// Kuwaiti address shape — governorate/area/block/street, no ZIP codes.
@immutable
class KuwaitAddress {
  const KuwaitAddress({
    required this.governorate,
    required this.area,
    required this.block,
    required this.street,
    required this.building,
    this.floor,
    this.apartment,
    this.directions,
  });

  final String governorate;
  final String area;
  final String block;
  final String street;
  final String building;
  final String? floor;
  final String? apartment;
  final String? directions;

  Map<String, dynamic> toJson() => {
        'governorate': governorate,
        'area': area,
        'block': block,
        'street': street,
        'building': building,
        'floor': floor,
        'apartment': apartment,
        'directions': directions,
      };

  factory KuwaitAddress.fromJson(Map<dynamic, dynamic> json) => KuwaitAddress(
        governorate: json['governorate'] as String,
        area: json['area'] as String,
        block: json['block'] as String,
        street: json['street'] as String,
        building: json['building'] as String,
        floor: json['floor'] as String?,
        apartment: json['apartment'] as String?,
        directions: json['directions'] as String?,
      );

  String get summary => [
        area,
        'Block $block',
        'St. $street',
        'Bldg $building',
        if (floor != null && floor!.isNotEmpty) 'Floor $floor',
        if (apartment != null && apartment!.isNotEmpty) 'Apt $apartment',
      ].join(', ');
}

/// The six governorates of Kuwait: (english, arabic).
const kuwaitGovernorates = <(String, String)>[
  ('Al Asimah (Capital)', 'العاصمة'),
  ('Hawalli', 'حولي'),
  ('Farwaniya', 'الفروانية'),
  ('Mubarak Al-Kabeer', 'مبارك الكبير'),
  ('Ahmadi', 'الأحمدي'),
  ('Jahra', 'الجهراء'),
];

enum OrderStatus {
  pendingPayment,
  paid,
  codConfirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

enum PaymentMethod { knet, card, applePay, cod }

@immutable
class OrderLine {
  const OrderLine({
    required this.sku,
    required this.productSlug,
    required this.productName,
    required this.productNameAr,
    required this.emoji,
    required this.tile,
    required this.unitPriceFils,
    required this.qty,
  });

  // Denormalized snapshots — immune to later catalog edits (spec §2.2).
  final String sku;
  final String productSlug;
  final String productName;
  final String productNameAr;
  final String emoji;
  final int tile;
  final int unitPriceFils;
  final int qty;

  Money get unitPrice => Money(unitPriceFils);
  Money get lineTotal => unitPrice * qty;

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'productSlug': productSlug,
        'productName': productName,
        'productNameAr': productNameAr,
        'emoji': emoji,
        'tile': tile,
        'unitPriceFils': unitPriceFils,
        'qty': qty,
      };

  factory OrderLine.fromJson(Map<dynamic, dynamic> json) => OrderLine(
        sku: json['sku'] as String,
        productSlug: json['productSlug'] as String,
        productName: json['productName'] as String,
        productNameAr: json['productNameAr'] as String,
        emoji: json['emoji'] as String,
        tile: json['tile'] as int,
        unitPriceFils: json['unitPriceFils'] as int,
        qty: json['qty'] as int,
      );
}

@immutable
class OrderEvent {
  const OrderEvent({required this.status, required this.at, this.note});

  final OrderStatus status;
  final DateTime at;
  final String? note;

  Map<String, dynamic> toJson() =>
      {'status': status.name, 'at': at.toIso8601String(), 'note': note};

  factory OrderEvent.fromJson(Map<dynamic, dynamic> json) => OrderEvent(
        status: OrderStatus.values.byName(json['status'] as String),
        at: DateTime.parse(json['at'] as String),
        note: json['note'] as String?,
      );
}

@immutable
class Order {
  const Order({
    required this.orderNo,
    required this.email,
    required this.phone,
    required this.status,
    required this.paymentMethod,
    required this.lines,
    required this.address,
    required this.subtotalFils,
    required this.shippingFils,
    required this.discountFils,
    required this.totalFils,
    required this.placedAt,
    required this.events,
  });

  final String orderNo;
  final String email;
  final String phone;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final List<OrderLine> lines;
  final KuwaitAddress address;
  final int subtotalFils;
  final int shippingFils;
  final int discountFils;
  final int totalFils;
  final DateTime placedAt;
  final List<OrderEvent> events;

  Money get subtotal => Money(subtotalFils);
  Money get shipping => Money(shippingFils);
  Money get discount => Money(discountFils);
  Money get total => Money(totalFils);

  Map<String, dynamic> toJson() => {
        'orderNo': orderNo,
        'email': email,
        'phone': phone,
        'status': status.name,
        'paymentMethod': paymentMethod.name,
        'lines': lines.map((l) => l.toJson()).toList(),
        'address': address.toJson(),
        'subtotalFils': subtotalFils,
        'shippingFils': shippingFils,
        'discountFils': discountFils,
        'totalFils': totalFils,
        'placedAt': placedAt.toIso8601String(),
        'events': events.map((e) => e.toJson()).toList(),
      };

  factory Order.fromJson(Map<dynamic, dynamic> json) => Order(
        orderNo: json['orderNo'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        status: OrderStatus.values.byName(json['status'] as String),
        paymentMethod:
            PaymentMethod.values.byName(json['paymentMethod'] as String),
        lines: (json['lines'] as List)
            .map((e) => OrderLine.fromJson(Map<dynamic, dynamic>.from(e as Map)))
            .toList(),
        address:
            KuwaitAddress.fromJson(Map<dynamic, dynamic>.from(json['address'] as Map)),
        subtotalFils: json['subtotalFils'] as int,
        shippingFils: json['shippingFils'] as int,
        discountFils: json['discountFils'] as int,
        totalFils: json['totalFils'] as int,
        placedAt: DateTime.parse(json['placedAt'] as String),
        events: (json['events'] as List)
            .map((e) => OrderEvent.fromJson(Map<dynamic, dynamic>.from(e as Map)))
            .toList(),
      );

  Order copyWith({OrderStatus? status, List<OrderEvent>? events}) => Order(
        orderNo: orderNo,
        email: email,
        phone: phone,
        status: status ?? this.status,
        paymentMethod: paymentMethod,
        lines: lines,
        address: address,
        subtotalFils: subtotalFils,
        shippingFils: shippingFils,
        discountFils: discountFils,
        totalFils: totalFils,
        placedAt: placedAt,
        events: events ?? this.events,
      );
}

/// What checkout submits; the repository computes totals and assigns numbers.
@immutable
class DraftOrder {
  const DraftOrder({
    required this.email,
    required this.phone,
    required this.paymentMethod,
    required this.address,
    this.promoCode,
  });

  final String email;
  final String phone;
  final PaymentMethod paymentMethod;
  final KuwaitAddress address;
  final String? promoCode;
}
