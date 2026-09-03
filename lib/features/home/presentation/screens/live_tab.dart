import 'package:flutter/material.dart';

/// Up to 5 orders can be live at once — build this as a list from
/// day one, even though it will often show just 0 or 1 card. This is
/// the screen riders look at all shift, worth the extra design pass.
class LiveTab extends StatelessWidget {
  const LiveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('TODO: live orders (polling provider goes here)')),
    );
  }
}
