import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/orders_repository.dart';
import '../../domain/order_detail.dart';

/// Keyed by orderId, and deliberately **not** cached between visits.
///
/// An order's status moves underneath us (Accepted → Processing →
/// In_Delivery → Delivered) while the app is open. Caching meant
/// reopening an order showed whatever status it had the first time it
/// was viewed — e.g. a delivered order still reading "Accepted", with
/// a Mark Delivered button the backend would now reject. autoDispose
/// drops the value once the screen closes, so each visit refetches.
final orderDetailProvider =
    FutureProvider.autoDispose.family<OrderDetail, int>((ref, orderId) {
  return ref.read(ordersRepositoryProvider).fetchOrderDetail(orderId);
});
