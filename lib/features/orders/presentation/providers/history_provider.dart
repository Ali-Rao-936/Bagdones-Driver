import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/orders_repository.dart';
import '../../domain/order.dart';

class HistoryState {
  const HistoryState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<Order> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  HistoryState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) => HistoryState(
        orders: orders ?? this.orders,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: error,
      );
}

class HistoryNotifier extends Notifier<HistoryState> {
  int _page = 0;

  @override
  HistoryState build() {
    // Kick off the first load without blocking build() itself —
    // same pattern as AuthNotifier's _bootstrap().
    Future.microtask(refresh);
    return const HistoryState(isLoading: true);
  }

  OrdersRepository get _repository => ref.read(ordersRepositoryProvider);

  Future<void> refresh() async {
    _page = 1;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.fetchOrders(page: _page);
      state = HistoryState(
        orders: result.orders.where((o) => o.status == 'Delivered').toList(),
        hasMore: result.hasMore,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Could not load history');
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final next = _page + 1;
      final result = await _repository.fetchOrders(page: next);
      _page = next;
      state = state.copyWith(
        orders: [
          ...state.orders,
          ...result.orders.where((o) => o.status == 'Delivered'),
        ],
        isLoadingMore: false,
        hasMore: result.hasMore,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(
  HistoryNotifier.new,
);
