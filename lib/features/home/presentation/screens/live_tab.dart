import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exception.dart';
import '../../../orders/domain/order.dart';
import '../../../orders/presentation/providers/live_orders_provider.dart';
import '../../../orders/presentation/screens/order_details_screen.dart';
import '../../../orders/presentation/widgets/store_icon.dart';

class LiveTab extends ConsumerWidget {
  const LiveTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Live orders')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(liveOrdersProvider.notifier).refresh(),
        child: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, LiveOrdersState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.orders.isEmpty) {
      return const _ScrollableMessage(
          text: 'Could not load live orders — pull to retry');
    }
    if (state.orders.isEmpty) {
      return const _ScrollableMessage(text: 'No live orders right now');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        final order = state.orders[index];
        return _LiveOrderCard(
          key: ValueKey(order.id),
          order: order,
          isNew: state.newOrderIds.contains(order.id),
          onViewDetails: () {
            ref.read(liveOrdersProvider.notifier).acknowledge(order.id);
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => OrderDetailsScreen(orderId: order.id)),
            );
          },
        );
      },
    );
  }
}

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

String _relativeTime(DateTime? time) {
  if (time == null) return '';
  final diff = DateTime.now().difference(time.toLocal());
  if (diff.inMinutes < 1) return 'Assigned just now';
  if (diff.inMinutes < 60) return 'Assigned ${diff.inMinutes} min ago';
  return 'Assigned ${diff.inHours} hr ago';
}

Color _statusColor(BuildContext context, String status) {
  switch (status) {
    case 'Accepted':
      return Colors.amber.shade700;
    case 'Processing':
      return Colors.indigo.shade400;
    case 'In_Delivery':
      return Colors.green.shade600;
    default:
      return Theme.of(context).colorScheme.outline;
  }
}

class _LiveOrderCard extends ConsumerStatefulWidget {
  const _LiveOrderCard({
    super.key,
    required this.order,
    required this.isNew,
    required this.onViewDetails,
  });

  final Order order;
  final bool isNew;
  final VoidCallback onViewDetails;

  @override
  ConsumerState<_LiveOrderCard> createState() => _LiveOrderCardState();
}

class _LiveOrderCardState extends ConsumerState<_LiveOrderCard> {
  bool _isMarkingDelivered = false;

  Future<void> _markDelivered() async {
    setState(() => _isMarkingDelivered = true);
    try {
      await ref
          .read(liveOrdersProvider.notifier)
          .markDelivered(widget.order.id);
      // No need to reset the flag on success — this card is about to
      // disappear entirely once the order leaves state.orders.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isMarkingDelivered = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isMarkingDelivered = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not mark as delivered')),
      );
    }
  }

  Future<void> _openMaps(String? url) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location available for this order')),
      );
      return;
    }
    // Assumes the backend's google_maps_url already starts turn-by-
    // turn directions rather than just dropping a pin — unverified
    // until tested against a real order. If it only opens a place
    // page instead of directions, ask the backend for raw lat/lng so
    // we can build our own maps/dir?api=1&destination=... link.
    final launched =
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final color = _statusColor(context, order.status);

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) => widget.onViewDetails(),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            icon: Icons.visibility_outlined,
            label: 'View',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        color: widget.isNew ? color.withValues(alpha: 0.08) : null,
        // Tapping anywhere on the card opens details — swiping to
        // reveal "View" is a shortcut, not the only way in.
        child: InkWell(
          onTap: widget.onViewDetails,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.isNew)
                              Row(
                                children: [
                                  _PulsingDot(color: color),
                                  const SizedBox(width: 6),
                                  Text(
                                    'New',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ],
                              )
                            else
                              const SizedBox.shrink(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.status.replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _DestinationRow(
                          icon: Icons.storefront_outlined,
                          label: order.storeName,
                          iconUrl: order.storeIconUrl,
                          onNavigate: order.storeMapsUrl == null
                              ? null
                              : () => _openMaps(order.storeMapsUrl),
                        ),
                        const SizedBox(height: 14),
                        _DestinationRow(
                          icon: Icons.location_on_outlined,
                          label: order.clientName ?? 'Customer',
                          onNavigate: order.clientMapsUrl == null
                              ? null
                              : () => _openMaps(order.clientMapsUrl),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _relativeTime(order.updatedAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            Text(
                              order.total.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                        // Only the driver's one allowed transition —
                        // hidden entirely for Accepted/Processing since
                        // the backend would reject the call anyway.
                        if (order.status == 'In_Delivery') ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed:
                                  _isMarkingDelivered ? null : _markDelivered,
                              style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green.shade600),
                              icon: _isMarkingDelivered
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check, size: 18),
                              label: const Text('Mark delivered'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DestinationRow extends StatelessWidget {
  const _DestinationRow({
    required this.icon,
    required this.label,
    required this.onNavigate,
    this.iconUrl,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onNavigate;

  /// Store logo, when there is one. The customer row has none.
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;

    return Row(
      children: [
        if (iconUrl != null)
          StoreIcon(
            url: iconUrl!,
            fallbackIcon: icon,
            accentColor: secondary,
            collapsedSize: 18,
            expandedSize: 30,
          )
        else
          Icon(icon, size: 18, color: secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onNavigate != null)
          // 40px so it is comfortably tappable with a thumb on the
          // move — the old 24px circle was well under the usable
          // minimum for a driver holding a phone one-handed.
          InkWell(
            onTap: onNavigate,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.navigation_outlined, size: 20, color: secondary),
            ),
          ),
      ],
    );
  }
}

/// A small looping fade — the "this just arrived" cue on the card
/// design. Self-contained animation, disposes its own controller.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
