import '../../../core/network/json_coerce.dart';

/// Matches the driver-visible fields of `OrderResource`. Only what
/// History and Live need so far — items/store phone/etc. will get
/// added once we build the Order Details screen.
class Order {
  const Order({
    required this.id,
    required this.reference,
    required this.status,
    required this.storeName,
    required this.deliveryFee,
    required this.total,
    this.storeIconUrl,
    this.deliveredAt,
    this.updatedAt,
    this.storeMapsUrl,
    this.clientName,
    this.clientMapsUrl,
  });

  /// Field names below are confirmed against a real
  /// `GET /delivery/orders` response, not the doc — several differ:
  /// the maps key is `google_maps_link`, there is no `client` object
  /// (the customer is flattened into `client_address`/`client_phone`),
  /// and the order timestamp is `date`, not `updated_at`.
  /// Alternate keys are kept as fallbacks so this keeps working if
  /// the backend later adds the documented names.
  factory Order.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>?;
    final clientAddress = json['client_address'] as Map<String, dynamic>?;
    return Order(
      id: asInt(json['id']),
      reference: json['reference'] as String? ?? '',
      status: json['status'] as String? ?? '',
      storeName: store?['name'] as String? ?? 'Unknown store',
      deliveryFee: asDouble(json['delivery_fee']),
      // What the rider collects at the door — more useful on the card
      // than the fee, which is only their own cut.
      total: asDouble(json['total']),
      storeIconUrl: (store?['icon'] as Map<String, dynamic>?)?['path'] as String?,
      deliveredAt: asDate(json['delivered_at']),
      updatedAt: asDate(json['date'] ?? json['updated_at']),
      storeMapsUrl:
          (store?['google_maps_link'] ?? store?['google_maps_url']) as String?,
      // The API exposes no customer *name* to drivers, so this holds
      // the delivery area — which is what the "Delivery to" row
      // actually wants to show anyway.
      clientName: (clientAddress?['area'] ?? clientAddress?['city']) as String?,
      clientMapsUrl: (clientAddress?['google_maps_link'] ??
          clientAddress?['google_maps_url']) as String?,
    );
  }

  final int id;
  final String reference;
  final String status;
  final String storeName;
  final double deliveryFee;
  final double total;
  final String? storeIconUrl;
  final DateTime? deliveredAt;
  final DateTime? updatedAt;
  final String? storeMapsUrl;
  final String? clientName;
  final String? clientMapsUrl;

  /// Anything not yet Delivered counts as "active" for the Live tab —
  /// matches the doc's note that Active can include Accepted/
  /// Processing if the admin assigned the driver early, not just
  /// In_Delivery.
  bool get isActive => status != 'Delivered';
}

/// One page of the orders list, plus enough pagination info to know
/// whether there's a next page.
class OrderPage {
  const OrderPage({
    required this.orders,
    required this.currentPage,
    required this.hasMore,
  });

  final List<Order> orders;
  final int currentPage;
  final bool hasMore;
}
