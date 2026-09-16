import 'package:flutter/material.dart';

/// Store logo that starts compact and grows once the image actually
/// decodes, so a slow or missing icon never reserves a large empty
/// box. Falls back to [fallbackIcon] if the URL fails.
///
/// Shared by the Live card and Order Details, which want different
/// sizes — hence the two size knobs rather than fixed values.
class StoreIcon extends StatefulWidget {
  const StoreIcon({
    super.key,
    required this.url,
    required this.fallbackIcon,
    required this.accentColor,
    this.collapsedSize = 22,
    this.expandedSize = 44,
  });

  final String url;
  final IconData fallbackIcon;
  final Color accentColor;
  final double collapsedSize;
  final double expandedSize;

  @override
  State<StoreIcon> createState() => _StoreIconState();
}

class _StoreIconState extends State<StoreIcon> {
  bool _loaded = false;
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Icon(
        widget.fallbackIcon,
        size: widget.collapsedSize,
        color: widget.accentColor,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _loaded ? widget.expandedSize : widget.collapsedSize,
      height: _loaded ? widget.expandedSize : widget.collapsedSize,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.network(
        widget.url,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame != null && !_loaded) {
            // Can't setState during build, so defer a frame.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _loaded = true);
            });
          }
          return child;
        },
        errorBuilder: (context, error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_failed) setState(() => _failed = true);
          });
          return Icon(
            widget.fallbackIcon,
            size: widget.collapsedSize * 0.9,
            color: widget.accentColor,
          );
        },
      ),
    );
  }
}
