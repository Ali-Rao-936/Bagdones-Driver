import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_client_provider.dart';
import '../domain/order.dart';

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
}

/// Shared across History and (later) the Live tab — both hit the
/// same endpoint, just filtered differently.
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(ref.read(apiClientProvider));
});
