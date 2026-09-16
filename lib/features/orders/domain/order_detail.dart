import '../../../core/network/json_coerce.dart';

/// The full OrderResource returned by GET /delivery/orders/{id} —
/// richer than the list-view Order model (store/client phone, items,
/// note).
class OrderDetail {
  const OrderDetail({
    required this.id,
    required this.reference,
    required this.status,
    required this.storeName,
    required this.storePhone,
    required this.storeMapsUrl,
    required this.clientName,
    required this.clientPhone,
    required this.clientMapsUrl,
    required this.items,
    required this.note,
    required this.deliveryFee,
    required this.total,
    this.deliveredAt,
    this.storeIconUrl,
  });

  /// Keys confirmed against a real orders response: the store's phone
  /// is `phone_number`, maps links are `google_maps_link`, and there
  /// is no `client` object — the customer is flattened into
  /// `client_phone` and `client_address`, with no name exposed to
  /// drivers. Documented alternates are kept as fallbacks.
  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>?;
    final clientAddress = json['client_address'] as Map<String, dynamic>?;
    final itemsJson = json['items'] as List<dynamic>? ?? const [];

    return OrderDetail(
      id: asInt(json['id']),
      reference: json['reference'] as String? ?? '',
      status: json['status'] as String? ?? '',
      storeName: store?['name'] as String? ?? 'Unknown store',
      storePhone: (store?['phone_number'] ?? store?['phone']) as String?,
      storeMapsUrl:
          (store?['google_maps_link'] ?? store?['google_maps_url']) as String?,
      // No customer name in the payload — the full address is the
      // useful thing to show under "Delivery to".
      clientName: (clientAddress?['full_address'] ??
              clientAddress?['area']) as String? ??
          'Customer',
      clientPhone: json['client_phone'] as String?,
      clientMapsUrl: (clientAddress?['google_maps_link'] ??
          clientAddress?['google_maps_url']) as String?,
      items: itemsJson
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      note: (json['note'] ?? json['client_notes']) as String?,
      deliveryFee: asDouble(json['delivery_fee']),
      // What the rider actually collects on a cash delivery.
      total: asDouble(json['total']),
      deliveredAt: asDate(json['delivered_at']),
      storeIconUrl: (store?['icon'] as Map<String, dynamic>?)?['path'] as String?,
    );
  }

  final int id;
  final String reference;
  final String status;
  final String storeName;
  final String? storePhone;
  final String? storeMapsUrl;
  final String clientName;
  final String? clientPhone;
  final String? clientMapsUrl;
  final List<OrderItem> items;
  final String? note;
  final double deliveryFee;
  final double total;
  final DateTime? deliveredAt;
  final String? storeIconUrl;

  bool get isDelivered => status == 'Delivered';
}

class OrderItem {
  const OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.attributes,
    this.choices,
    this.compulsoryChoices = const [],
    this.multipleChoices = const [],
    this.selectedChoicesText,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // `choices_from_string` splits the selection into structured
    // lists, but in practice those come back empty while the real
    // selection ("Pistachio") sits in `selected_choices_string` /
    // `raw`. Read the typed lists when present and fall back to the
    // summary string, which is what actually carries the choice.
    final fromString = json['choices_from_string'] as Map<String, dynamic>?;

    return OrderItem(
      // Confirmed: items *do* carry `name` — the doc omitted it.
      name: json['name'] as String? ??
          json['product_name'] as String? ??
          json['title'] as String? ??
          'Item',
      quantity: asInt(json['quantity'], fallback: 1),
      // Prices are strings here too ("0.29").
      price: asDouble(json['price']),
      attributes: json['attributes'],
      choices: json['choices'],
      compulsoryChoices: _readChoiceList(fromString?['compulsory_choices']),
      multipleChoices: _readChoiceList(fromString?['multiple_choices']),
      selectedChoicesText:
          (json['selected_choices_string'] ?? fromString?['raw']) as String?,
    );
  }

  final String name;
  final int quantity;
  final double price;

  /// Shape unconfirmed — kept as raw dynamic and rendered
  /// defensively (see describeItemExtras below) rather than assumed.
  final dynamic attributes;
  final dynamic choices;

  /// Required and optional selections, from `choices_from_string`.
  final List<String> compulsoryChoices;
  final List<String> multipleChoices;

  /// Human-readable summary of the selection, e.g. "Pistachio". Used
  /// when the typed lists above are empty, which is the common case.
  final String? selectedChoicesText;

  /// Everything worth showing under the item name, or null if the
  /// order carries no options at all.
  String? get extrasLabel {
    final parts = <String>[...compulsoryChoices, ...multipleChoices];
    final summary = selectedChoicesText?.trim();
    if (parts.isEmpty && summary != null && summary.isNotEmpty) {
      parts.add(summary);
    }
    final other = describeItemExtras(attributes, choices);
    if (other != null) parts.add(other);
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

/// The lists' element shape isn't documented and came back empty on
/// the orders seen so far, so handle both plain strings and the usual
/// {name, value} map forms, and skip anything else rather than
/// rendering "Instance of ...".
List<String> _readChoiceList(Object? raw) {
  if (raw is! List) return const [];
  final out = <String>[];
  for (final entry in raw) {
    if (entry is String) {
      if (entry.trim().isNotEmpty) out.add(entry.trim());
    } else if (entry is Map) {
      final name = entry['name'] ?? entry['label'] ?? entry['title'];
      final value = entry['value'] ?? entry['choice'];
      if (name != null && value != null) {
        out.add('$name: $value');
      } else if (name != null) {
        out.add('$name');
      } else if (value != null) {
        out.add('$value');
      }
    }
  }
  return out;
}

/// Best-effort, shape-agnostic rendering of attributes/choices, since
/// neither is documented beyond the field name. Handles the common
/// cases (list of {name/attribute/label: value/choice} maps, or a
/// plain list of strings) and silently produces nothing for anything
/// else, rather than guessing wrong or crashing.
String? describeItemExtras(dynamic attributes, dynamic choices) {
  final parts = <String>[];
  for (final extra in [attributes, choices]) {
    if (extra is! List) continue;
    for (final entry in extra) {
      if (entry is Map) {
        final name = entry['name'] ?? entry['attribute'] ?? entry['label'];
        final value = entry['value'] ?? entry['choice'];
        if (name != null && value != null) {
          parts.add('$name: $value');
        } else if (name != null) {
          parts.add('$name');
        }
      } else if (entry is String) {
        parts.add(entry);
      }
    }
  }
  return parts.isEmpty ? null : parts.join(' · ');
}
