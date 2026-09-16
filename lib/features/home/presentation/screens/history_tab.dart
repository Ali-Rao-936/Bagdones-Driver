import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../orders/domain/order.dart';
import '../../../orders/presentation/providers/history_provider.dart';
import '../../../orders/presentation/screens/order_details_screen.dart';

class HistoryTab extends ConsumerStatefulWidget {
  const HistoryTab({super.key});

  @override
  ConsumerState<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends ConsumerState<HistoryTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(historyProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(historyProvider.notifier).refresh(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(HistoryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.orders.isEmpty) {
      return const _ScrollableMessage(text: 'Could not load history — pull to retry');
    }
    if (state.orders.isEmpty) {
      return const _ScrollableMessage(text: 'No deliveries yet');
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.orders.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.orders.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return _HistoryOrderCard(order: state.orders[index]);
      },
    );
  }
}

/// Wraps message text in a scrollable so pull-to-refresh still works
/// from the empty/error state, not just the populated list.
class _ScrollableMessage extends StatelessWidget {
  const _ScrollableMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryOrderCard extends StatelessWidget {
  const _HistoryOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final dateLabel = order.deliveredAt != null
        ? DateFormat('MMM d, h:mm a').format(order.deliveredAt!.toLocal())
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: order.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.storefront_outlined, size: 16),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.storeName, style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(
                      '$dateLabel · ${order.reference}',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                    ),
                  ],
                ),
              ),
              // Order total, matching the Live card — what the rider
              // collected, not their own delivery fee.
              // TODO: prefix with the actual currency once confirmed
              // — showing the raw number for now.
              Text(
                order.total.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
