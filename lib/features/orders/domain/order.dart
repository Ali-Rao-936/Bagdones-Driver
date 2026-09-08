/// Matches the driver-visible fields of `OrderResource`. Only what
/// the History list needs so far — items/store contact/etc. will get
/// added once we build the Order Details screen.
class Order {
  const Order({
    required this.id,
    required this.reference,
    required this.status,
    required this.storeName,
    required this.deliveryFee,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>?;
    return Order(
      id: json['id'] as int,
      reference: json['reference'] as String? ?? '',
      status: json['status'] as String? ?? '',
      storeName: store?['name'] as String? ?? 'Unknown store',
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'] as String)
          : null,
    );
  }

  final int id;
  final String reference;
  final String status;
  final String storeName;
  final double deliveryFee;
  final DateTime? deliveredAt;
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
