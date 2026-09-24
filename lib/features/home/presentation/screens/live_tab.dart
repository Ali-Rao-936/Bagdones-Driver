import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exception.dart';
import '../../../orders/domain/order.dart';
import '../../../orders/presentation/providers/live_orders_provider.dart';
import '../../../orders/presentation/screens/order_details_screen.dart';
import '../../../orders/presentation/widgets/store_icon.dart';
import '../../../../l10n/app_localizations.dart';

class LiveTab extends ConsumerWidget {
  const LiveTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(liveOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.liveTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(liveOrdersProvider.notifier).refresh(),
        child: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, LiveOrdersState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.orders.isEmpty) {
      return _ScrollableMessage(text: l10n.liveError);
    }
    if (state.orders.isEmpty) {
      return _ScrollableMessage(text: l10n.liveEmpty);
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

String _relativeTime(AppLocalizations l10n, DateTime? time) {
  if (time == null) return '';
  final diff = DateTime.now().difference(time.toLocal());
  if (diff.inMinutes < 1) return l10n.liveAssignedJustNow;
  if (diff.inMinutes < 60) return l10n.liveAssignedMinutesAgo(diff.inMinutes);
  return l10n.liveAssignedHoursAgo(diff.inHours);
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
  bool _isUpdating = false;

  /// Runs one of the driver's status transitions, showing the
  /// backend's own message on an ApiException and [failedMessage]
  /// for anything else.
  Future<void> _transition(
    Future<void> Function(LiveOrdersNotifier notifier) call,
    String failedMessage,
  ) async {
    setState(() => _isUpdating = true);
    try {
      await call(ref.read(liveOrdersProvider.notifier));
      // Mark Delivered removes this card entirely; Start Delivery
      // rebuilds it with the new status, so clear the flag if we're
      // still here.
      if (mounted) setState(() => _isUpdating = false);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failedMessage)));
    }
  }

  Future<void> _openMaps(String? url) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.orderDetailsNoLocation)),
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
        SnackBar(content: Text(AppLocalizations.of(context)!.orderDetailsMapsFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            label: l10n.liveView,
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
                                    l10n.liveNewBadge,
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
                              _relativeTime(l10n, order.updatedAt),
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
                        // Only the driver's two legal transitions, each
                        // shown only when the backend would accept it —
                        // nothing at all for Accepted.
                        if (order.status == 'Processing')
                          _TransitionButton(
                            label: l10n.liveStartDelivery,
                            icon: Icons.delivery_dining,
                            color: Colors.indigo.shade400,
                            isBusy: _isUpdating,
                            onPressed: () => _transition(
                              (n) => n.startDelivery(order.id),
                              l10n.liveStartDeliveryFailed,
                            ),
                          )
                        else if (order.status == 'In_Delivery')
                          _TransitionButton(
                            label: l10n.liveMarkDelivered,
                            icon: Icons.check,
                            color: Colors.green.shade600,
                            isBusy: _isUpdating,
                            onPressed: () => _transition(
                              (n) => n.markDelivered(order.id),
                              l10n.liveMarkDeliveredFailed,
                            ),
                          ),
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

class _TransitionButton extends StatelessWidget {
  const _TransitionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isBusy,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: isBusy ? null : onPressed,
          style: FilledButton.styleFrom(backgroundColor: color),
          icon: isBusy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, size: 18),
          label: Text(label),
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
