import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_client_provider.dart';
import '../domain/order.dart';
import '../domain/order_detail.dart';

class OrdersRepository {
  OrdersRepository(this._client);

  final ApiClient _client;

  /// GET /delivery/orders — every order assigned to this driver, any
  /// status. The doc doesn't document a status filter query param,
  /// so History currently fetches everything and filters client-side
  /// to Delivered (see historyProvider). Worth asking the backend for
  /// a real ?status= filter once order volume grows — client-side
  /// filtering means a "page" can come back with fewer visible rows
  /// than the limit.
  Future<OrderPage> fetchOrders({int page = 1, int limit = 20}) async {
    final response = await _client.get(
      '/delivery/orders',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = _client.unwrap(response);

    // Confirmed shape (GET /delivery/orders):
    //   {errors, data: {data: [...], pagination: {total, count,
    //    per_page, current_page, total_pages}}, message, code}
    // Note the paging info sits under `pagination` and the last-page
    // key is `total_pages` — reading current_page/last_page off the
    // top level yields nulls, which collapses hasMore to
    // `1 < 1 == false` and silently kills infinite scroll.
    final rawList = data['data'] as List<dynamic>? ??
        data['orders'] as List<dynamic>? ??
        const [];
    final orders =
        rawList.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();

    final pagination = data['pagination'] as Map<String, dynamic>?;
    final currentPage = pagination?['current_page'] as int? ?? page;
    final totalPages = pagination?['total_pages'] as int? ?? currentPage;

    return OrderPage(
      orders: orders,
      currentPage: currentPage,
      hasMore: currentPage < totalPages,
    );
  }

  /// PATCH /delivery/orders/{id}/in-delivery — Processing →
  /// In_Delivery, i.e. the driver has picked the order up. Rejections
  /// surface as typed ApiExceptions with the backend's own message,
  /// same as [markDelivered]. The response body is ignored; callers
  /// refetch to see the new status.
  Future<void> startDelivery(int orderId) async {
    await _client.patch('/delivery/orders/$orderId/in-delivery');
  }

  /// PATCH /delivery/orders/{id}/deliver — In_Delivery → Delivered.
  /// Backend enforces: 403 if inactive/not your order, 400 if already
  /// Delivered, 422 if status isn't In_Delivery yet — all three
  /// already surface as typed ApiExceptions with the backend's own
  /// message via ApiClient.
  Future<void> markDelivered(int orderId) async {
    await _client.patch('/delivery/orders/$orderId/deliver');
  }

  /// GET /delivery/orders/{id} — the richer single-order view (store/
  /// client contact, items, note) for the Order Details screen.
  /// Assumes the envelope puts the order fields directly under
  /// 'data' with no further nesting (unlike login's data.delivery_man)
  /// — unverified. If this throws the familiar "Null is not a
  /// subtype of Map" error, print(response.data) here same as before.
  Future<OrderDetail> fetchOrderDetail(int orderId) async {
    final response = await _client.get('/delivery/orders/$orderId');
    final data = _client.unwrap(response);
    return OrderDetail.fromJson(data);
  }
}

/// Shared across History and the Live tab — both hit the
/// same endpoint, just filtered differently.
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(ref.read(apiClientProvider));
});
