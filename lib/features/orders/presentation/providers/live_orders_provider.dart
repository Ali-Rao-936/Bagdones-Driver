import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/push_service.dart';
import '../../data/orders_repository.dart';
import '../../domain/order.dart';
import 'history_provider.dart';

class LiveOrdersState {
  const LiveOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.newOrderIds = const {},
  });

  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final Set<int> newOrderIds;

  LiveOrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    Set<int>? newOrderIds,
  }) => LiveOrdersState(
        orders: orders ?? this.orders,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        newOrderIds: newOrderIds ?? this.newOrderIds,
      );
}

class LiveOrdersNotifier extends Notifier<LiveOrdersState> {
  Timer? _pollTimer;
  StreamSubscription<void>? _pushSub;
  final _seenOrderIds = <int>{};

  @override
  LiveOrdersState build() {
    ref.onDispose(() {
      _pollTimer?.cancel();
      _pushSub?.cancel();
    });

    Future.microtask(() async {
      await refresh();
      _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());

      // A push means something changed server-side; refresh rather
      // than trusting the payload. PushService.start() is already
      // called at app startup, so we only subscribe here.
      _pushSub = ref.read(pushServiceProvider).onForegroundMessage.listen(
            (_) => refresh(),
          );
    });

    return const LiveOrdersState(isLoading: true);
  }

  OrdersRepository get _repository => ref.read(ordersRepositoryProvider);

  Future<void> refresh() async {
    try {
      // Only page 1 — up to 5 concurrent orders per driver, no
      // pagination needed here the way History needs it.
      final result = await _repository.fetchOrders(page: 1, limit: 20);
      final active = result.orders.where((o) => o.isActive).toList();
      final activeIds = active.map((o) => o.id).toSet();

      // Don't flag everything as "new" on the very first load — only
      // orders that appear on a *later* poll count as newly arrived.
      final freshlySeen =
          _seenOrderIds.isEmpty ? <int>{} : activeIds.difference(_seenOrderIds);
      _seenOrderIds
        ..clear()
        ..addAll(activeIds);

      final stillRelevantNew = {...state.newOrderIds, ...freshlySeen}
        ..removeWhere((id) => !activeIds.contains(id));

      state = state.copyWith(
        orders: active,
        isLoading: false,
        error: null,
        newOrderIds: stillRelevantNew,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Could not load live orders');
    }
  }

  /// Call when the driver taps into an order, so the "New" badge and
  /// pulse only show until it's actually been looked at.
  void acknowledge(int orderId) {
    final updated = {...state.newOrderIds}..remove(orderId);
    state = state.copyWith(newOrderIds: updated);
  }

  /// Processing → In_Delivery. The order stays in Live, so refetch
  /// rather than patching it locally — that also picks up anything
  /// else the backend changed alongside the status. Throws on failure,
  /// like [markDelivered].
  Future<void> startDelivery(int orderId) async {
    await _repository.startDelivery(orderId);
    await refresh();
  }

  /// Calls the API, then removes the order from Live immediately
  /// rather than waiting for the next 30s poll, and invalidates
  /// historyProvider so the now-Delivered order is already there
  /// the moment the driver switches tabs. Throws on failure — the
  /// UI shows the backend's own error message (e.g. "Order status
  /// invalid: current Accepted, next is Processing...").
  Future<void> markDelivered(int orderId) async {
    await _repository.markDelivered(orderId);
    state = state.copyWith(
      orders: state.orders.where((o) => o.id != orderId).toList(),
    );
    _seenOrderIds.remove(orderId);
    ref.invalidate(historyProvider);
  }
}

final liveOrdersProvider = NotifierProvider<LiveOrdersNotifier, LiveOrdersState>(
  LiveOrdersNotifier.new,
);
