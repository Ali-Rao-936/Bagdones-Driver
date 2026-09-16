import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/order_detail.dart';
import '../providers/live_orders_provider.dart';
import '../providers/order_detail_provider.dart';
import '../widgets/store_icon.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final int orderId;

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  bool _isMarkingDelivered = false;

  Future<void> _markDelivered() async {
    setState(() => _isMarkingDelivered = true);
    try {
      await ref.read(liveOrdersProvider.notifier).markDelivered(widget.orderId);
      // The cached detail still says In_Delivery; drop it so a later
      // visit refetches instead of showing a stale status and a
      // button the backend would now reject.
      ref.invalidate(orderDetailProvider(widget.orderId));
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isMarkingDelivered = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isMarkingDelivered = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not mark as delivered')),
      );
    }
  }

  Future<void> _call(String? phone) async {
    if (phone == null) return;
    final launched = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the dialer')),
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
    final launched = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(orderDetailProvider(widget.orderId));
    final driverName = ref.watch(authProvider).driver?.name;

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error is ApiException ? error.message : 'Could not load order details',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (detail) => _buildBody(context, detail, driverName),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderDetail detail, String? driverName) {
    final statusColor = _statusColor(context, detail.status);
    // Once delivered, pickup/dropoff are history rather than things to
    // act on, so the cards drop their live coral/teal accents.
    final muted = Theme.of(context).colorScheme.outlineVariant;
    final pickupAccent = detail.isDelivered ? muted : const Color(0xFF993C1D);
    final dropoffAccent = detail.isDelivered ? muted : const Color(0xFF0F6E56);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                detail.reference,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                detail.status.replaceAll('_', ' '),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        // A completed order reads differently from a live one: say so
        // up front, with when it happened, instead of showing the same
        // screen as an order still being driven around.
        if (detail.isDelivered) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _deliveredColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 18, color: _deliveredColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detail.deliveredAt == null
                        ? 'Delivered'
                        : 'Delivered ${DateFormat('MMM d, h:mm a').format(detail.deliveredAt!.toLocal())}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _deliveredColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Pickup',
          icon: Icons.storefront_outlined,
          name: detail.storeName,
          phone: detail.storePhone,
          accentColor: pickupAccent,
          iconUrl: detail.storeIconUrl,
          onCall: () => _call(detail.storePhone),
          onNavigate: detail.storeMapsUrl == null ? null : () => _openMaps(detail.storeMapsUrl),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Delivery to',
          icon: Icons.location_on_outlined,
          name: detail.clientName,
          phone: detail.clientPhone,
          accentColor: dropoffAccent,
          onCall: () => _call(detail.clientPhone),
          onNavigate: detail.clientMapsUrl == null ? null : () => _openMaps(detail.clientMapsUrl),
        ),
        if (driverName != null) ...[
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Driver'),
              subtitle: Text(driverName),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text('Items', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < detail.items.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _ItemRow(item: detail.items[i]),
              ],
              if (detail.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No item details available'),
                ),
            ],
          ),
        ),
        if (detail.note != null && detail.note!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Note', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(detail.note!),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery fee',
                      style: TextStyle(color: Theme.of(context).colorScheme.outline),
                    ),
                    Text(detail.deliveryFee.toStringAsFixed(2)),
                  ],
                ),
                const Divider(height: 18),
                // Emphasised because this is the figure the rider
                // collects from the customer at the door.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total to collect',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      detail.total.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Same rule as Live: only the driver's one allowed
        // transition, only shown when it's actually legal to call.
        if (detail.status == 'In_Delivery') ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isMarkingDelivered ? null : _markDelivered,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: _isMarkingDelivered
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check),
              label: const Text('Mark delivered'),
            ),
          ),
        ],
        // Keeps the total (and the button, when shown) off the bottom
        // edge instead of butting against it.
        const SizedBox(height: 32),
      ],
    );
  }
}

const _deliveredColor = Color(0xFF2E7D32);

Color _statusColor(BuildContext context, String status) {
  switch (status) {
    case 'Accepted':
      return Colors.amber.shade700;
    case 'Processing':
      return Colors.indigo.shade400;
    case 'In_Delivery':
      return Colors.green.shade600;
    case 'Delivered':
      return _deliveredColor;
    default:
      return Theme.of(context).colorScheme.outline;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.name,
    required this.phone,
    required this.accentColor,
    required this.onCall,
    required this.onNavigate,
    this.iconUrl,
  });

  final String title;
  final IconData icon;
  final String name;
  final String? phone;
  final Color accentColor;
  final VoidCallback onCall;
  final VoidCallback? onNavigate;

  /// Store logo, when the API supplies one. Falls back to [icon].
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: accentColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (iconUrl != null) ...[
                  StoreIcon(url: iconUrl!, fallbackIcon: icon, accentColor: accentColor),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ],
            ),
            if (phone != null) ...[
              const SizedBox(height: 2),
              Text(phone!, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline)),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (phone != null)
                  OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.call_outlined, size: 16),
                    label: const Text('Call'),
                  ),
                if (phone != null && onNavigate != null) const SizedBox(width: 8),
                if (onNavigate != null)
                  OutlinedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.navigation_outlined, size: 16),
                    label: const Text('Navigate'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final extras = item.extrasLabel;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${item.quantity}×', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (extras != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    extras,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(item.price.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
